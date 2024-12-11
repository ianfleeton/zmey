module Admin
  class ImportController < AdminController
    ALLOW_LIST = ["Page", "Product", "ProductGroup"].freeze

    def index
    end

    def csv
      return head(403) unless ALLOW_LIST.include?(params[:class_name])

      if params[:csv].present?
        fn = "#{SecureRandom.hex[0, 8]}-#{params[:csv].original_filename}"
        path = File.join("tmp", fn)
        File.write(path, File.read(params[:csv].tempfile))

        CSVImportJob.perform_later(path, params[:class_name])

        notice = I18n.t("controllers.admin.import.csv.import_in_progress")
      else
        notice = I18n.t("controllers.admin.import.csv.nothing_uploaded")
      end
      redirect_to admin_import_index_path, notice: notice
    end
  end
end
