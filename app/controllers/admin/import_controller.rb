class Admin::ImportController < Admin::AdminController
  def index
  end

  def csv
    if params[:csv]
      fn = "#{SecureRandom.hex[0,8]}-#{params[:csv].original_filename}"
      path = File.join('tmp', fn)
      File.open(path, 'w') {|f| f.write(File.read(params[:csv].tempfile))}

      importer = CSVImporter.new(path, params[:class_name])
      if Rails.env.production?
        importer.delay.import
      else
        importer.import
      end
      notice = I18n.t('controllers.admin.import.csv.import_in_progress')
    else
      notice = I18n.t('controllers.admin.import.csv.nothing_uploaded')
    end
    redirect_to admin_import_index_path, notice: notice
  end
end
