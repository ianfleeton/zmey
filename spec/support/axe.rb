# frozen_string_literal: true

# Accessibility checks with axe-core, run through Playwright.
#
# Deque's axe-core Ruby gems only drive browsers through WebDriver, so this
# injects axe-core (from node_modules) into the page with Playwright and runs
# it there. The matcher follows axe-core-rspec's chainable API:
#
#   expect(page).to be_axe_clean
#   expect(page).to be_axe_clean.within(".content-main").excluding("#widget")
#   expect(page).to be_axe_clean.according_to(:wcag2a, :wcag2aa)
#   expect(page).to be_axe_clean.skipping("color-contrast")
#
# Only the top-level document is checked; content inside iframes is not.
module Axe
  SOURCE_PATH = Rails.root.join("node_modules/axe-core/axe.min.js")

  # Runs axe-core against the current page and returns its results hash.
  def self.run(page, context:, options:)
    unless page.driver.respond_to?(:with_playwright_page)
      raise ArgumentError, "be_axe_clean needs the Playwright driver (tag the spec js: true)"
    end

    page.driver.with_playwright_page do |playwright_page|
      unless playwright_page.evaluate("() => typeof window.axe !== 'undefined'")
        playwright_page.add_script_tag(path: SOURCE_PATH.to_s)
      end
      playwright_page.evaluate(
        "([context, options]) => axe.run(context ?? document, options)",
        arg: [context, options]
      )
    end
  end

  # Formats violations for a failure message.
  def self.describe_violations(violations)
    violations.map.with_index(1) do |violation, i|
      nodes = violation["nodes"].map do |node|
        "    #{node["target"].join(" ")}\n      #{node["failureSummary"].to_s.gsub("\n", "\n      ")}"
      end
      "#{i}) #{violation["id"]} (#{violation["impact"]}): #{violation["help"]}\n" \
        "    #{violation["helpUrl"]}\n#{nodes.join("\n")}"
    end.join("\n\n")
  end
end

RSpec::Matchers.define :be_axe_clean do
  chain(:within) { |*selectors| (@include ||= []).concat(selectors.flatten) }
  chain(:excluding) { |*selectors| (@exclude ||= []).concat(selectors.flatten) }
  chain(:according_to) { |*tags| (@tags ||= []).concat(tags.flatten.map(&:to_s)) }
  chain(:skipping) { |*rules| (@skip ||= []).concat(rules.flatten.map(&:to_s)) }

  match do |page|
    context = {}
    context["include"] = @include if @include
    context["exclude"] = @exclude if @exclude
    context = context.empty? ? nil : context

    options = {}
    options["runOnly"] = {"type" => "tag", "values" => @tags} if @tags
    options["rules"] = @skip.to_h { |rule| [rule, {"enabled" => false}] } if @skip

    @violations = Axe.run(page, context: context, options: options).fetch("violations")
    @violations.empty?
  end

  failure_message do
    "Found #{@violations.size} accessibility violation(s):\n\n#{Axe.describe_violations(@violations)}"
  end

  failure_message_when_negated do
    "Expected accessibility violations, but found none"
  end
end
