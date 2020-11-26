import $ from 'jquery';

export default function imagePicker(object, attribute) {
  const imageField = object + '_' + attribute;
  const nextField = imageField + '_next';
  const prevField = imageField + '_prev';
  const imagesModal = imageField + '_images';
  const imagePicker = imageField + '_image_picker';
  const imageRemove = imageField + '_image_remove';
  const imagePreview = imageField + '_image_preview';
  let page = 1;

  $(document).on('input change keyup', '#' + imageField, function(_event) {
    const val = $(this).val();
    let src;
    if (val == '') {
      src = '/images/image-missing.png';
    } else {
      src = '/up/images/' + $(this).val() + '/image.jpg';
    }
    $('#' + imagePreview + ' img').attr('src', src);
  });

  $('#' + imagePicker).on('click', function(event) {
    event.preventDefault();
    $('#' + imagesModal).modal('show');
    getImages();
    return false;
  });

  $('#' + imageRemove).on('click', function(event) {
    event.preventDefault();
    $('#' + imageField).val('');
    $('#' + imagePreview + ' img').attr('src', '/images/image-missing.png');
  });

  function getImages() {
    $.getJSON('/admin/images', { page: page, per_page: 64 }, function(data) {
      var items = [];
      if(data.images.length == 0) {
        items.push('<li>No results found</li>');
      }
      if(data.current_page > 1 || data.current_page < data.total_pages) {
        items.push('<li><div class="btn-group">');
        items.push(arrowButton(prevField, 'Previous', 'left', data.current_page > 1));
        items.push(arrowButton(nextField, 'Next', 'right', data.current_page < data.total_pages));
        items.push('</div></li>');
      }
      $.each(data.images, function(key, image) {
        var i = '<li class="picker-image"><button type="button" data-id="' + image.id + '" id="image-' + image.id + '"><img src="/up/images/' + image.id + '/constrained.192x144.jpg" title="' + image.name + '"></button></li>';
        items.push(i);
      });
      $('#' + imagesModal + ' .results-body').replaceWith(
        $('<ul/>', {
          'class': 'clearfix results-body',
          html: items.join('')
        })
      );
      $('#' + nextField).on('click', function() {
        page += 1;
        getImages();
        setTimeout(function() { $('#' + imagesModal).modal('show') }, 500);
      });
      $('#' + prevField).on('click', function() {
        page -= 1;
        getImages();
        setTimeout(function() { $('#' + imagesModal).modal('show') }, 500);
      });
      $('#' + imagesModal + ' .results-body button').on('click', function() {
        $('#' + imageField).val($(this).data('id'));
        $('#' + imagesModal).modal('hide');
        $('#' + imagePreview + ' img').attr('src', $(this).find('img').attr('src'));
        return false;
      });
    });
  }

  function arrowButton(id, title, icon, active) {
    const items = [];
    items.push('<a');
    if(active) {
      items.push(' id="' + id + '"');
    }
    items.push(' class="btn btn-outline-secondary');
    if(!active) {
      items.push(' disabled');
    }
    items.push('" title="' + title + '">');
    items.push('<i class="far fa-arrow-' + icon + '">');
    items.push('</i></a>');
    return items.join('');
  }
}
