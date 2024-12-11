import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const urlBase = this.data.get('urlBase')
    document.querySelector('#search button').addEventListener('click', function(event) {
      event.preventDefault()
      const query = document.querySelector('#search input').value
      fetch(urlBase + 'search?query=' + query)
        .then(response => response.json())
        .then(data => {
          const items = []
          if(data.length == 0) {
            items.push('<li>No results found</li>')
          }
          data.forEach(function(result) {
            var i = '<li><a href="' + urlBase + result.id + '/edit">' + result.name + '</a></li>'
            items.push(i)
          })
          document.querySelector('#search-results .modal-body').innerHTML = `<ul id="results-body">${items.join('')}</ul>`
          new bootstrap.Modal(document.getElementById('search-results')).show()
        })
    })
  }

  submit() {
  }
}
