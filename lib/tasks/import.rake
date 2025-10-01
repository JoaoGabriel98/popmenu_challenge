namespace :import do
  desc "Importa JSON de restaurantes: rake import:restaurants[path/to/restaurant_data.json]"
  task :restaurants, [ :path ] => :environment do |_, args|
    path = args[:path] or abort("Provide a JSON file path: rake import:restaurants[path/to/file.json]")
    payload = JSON.parse(File.read(path))
    result = Importers::RestaurantDataImporter.new(payload: payload).call
    puts JSON.pretty_generate(result)
    exit(result[:success] ? 0 : 1)
  end
end
