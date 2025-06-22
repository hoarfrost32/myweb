# _plugins/letterboxd_fetcher.rb

require "json"
require "net/http"
require "fileutils"

module Jekyll
  class LetterboxdFetcher < Generator
    safe true
    priority :highest

    def generate(site)
      # Get username from _config.yml, with a fallback
      username = site.config.dig("letterboxd", "username")
      if username.nil? || username.empty?
        puts "Letterboxd Fetcher: No username found in _config.yml. Skipping."
        return
      end
      
      # Define paths
      cache_dir = File.join(site.source, ".cache")
      cache_file = File.join(cache_dir, "letterboxd_feed.json")
      
      # Use cached data if it's less than a day old
      if File.exist?(cache_file) && (Time.now - File.mtime(cache_file)) < 86400 # 24 hours
        puts "Letterboxd Fetcher: Using cached data."
        begin
          json_data = JSON.parse(File.read(cache_file))
          site.data["letterboxd_films"] = json_data
          return
        rescue JSON::ParserError
          puts "Letterboxd Fetcher: Cache file is corrupt. Re-fetching."
        end
      end
      
      puts "Letterboxd Fetcher: Fetching fresh data from Letterboxd..."
      
      # Construct the API URL
      rss_url = "https://letterboxd.com/#{username}/rss/"
      api_url = "https://api.rss2json.com/v1/api.json?rss_url=#{URI.encode_www_form_component(rss_url)}"
      uri = URI(api_url)

      begin
        response = Net::HTTP.get_response(uri)
        
        if response.is_a?(Net::HTTPSuccess)
          json_data = JSON.parse(response.body)
          if json_data["status"] == "ok"
            # Save the good data to the cache
            FileUtils.mkdir_p(cache_dir)
            File.open(cache_file, "w") do |file|
              file.write(response.body)
            end
            
            # Make the data available to the site
            site.data["letterboxd_films"] = json_data
            puts "Letterboxd Fetcher: Successfully fetched and cached data."
          else
            puts "Letterboxd Fetcher: API Error - #{json_data['message']}"
          end
        else
          puts "Letterboxd Fetcher: HTTP Error - #{response.code} #{response.message}"
        end
      rescue StandardError => e
        puts "Letterboxd Fetcher: An error occurred during fetch - #{e.message}"
        puts e.backtrace
      end
    end
  end
end