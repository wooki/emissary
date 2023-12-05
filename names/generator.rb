require_relative './utils'
require_relative './name_sources'
require 'titleize'

module Emissary

class NameGenererator

    attr_accessor :region, :data

    @@rules = {
      persian: { desert: 31..100 },
      andalusian: { desert: 10..31 },
      scandinavian: { lowland: 0..10, mountain: 4..100, ocean: 50..100, peak: 0..20 },
      welsh: { lowland: 0..15, forest: 3..60, mountain: 3..60, peak: 0..1, town: 0..3 },
      italian: { ocean: 82..100 },
      germanic: { lowland: 3..50, forest: 2..100, ocean: 0..85 },
      fantasy: {} # Fallback generator
    }

    def self.get_region_for_terrain(terrain_hash)
      passed = passing_rules(terrain_hash, @@rules)
      passed.first      
    end

    def self.for_region(region)
      NameGenererator.new(region)
    end

    def get_name
      
      name = Array.new

      # add a prefix according to frequency
      if rand <= @data[:prefix_frequency]
        name.push @data[:prefixes].sample
      end

      main = Array.new

      # add start syllable
      main.push @data[:starts].sample

      # add middle syllable
      middle_length = @utils.random_key_with_frequency(@data[:syllable_lengths]).to_i
      middle_length.times do
        main.push @data[:middles].sample
      end

      # add end syllable
      main.push @data[:ends].sample

      name.push main.join('')

      # add suffix according to frequency
      if rand <= @data[:suffix_frequency]
        name.push @data[:suffixes].sample
      end
      
      n = name.join(' ').titleize
      return get_name if @data[:source].include? n.downcase
      n
    end
    
    private 
    
    def initialize(region)
      @region = region
      @utils = Emissary::NameUtils.new
      @names = Emissary::NameSources.new
      @data = @utils.get_data_for_words(@names.for_region(region))            
    end    

    def self.passing_rules(terrain_hash, rules)
      total_rating = terrain_hash.values.sum.to_f    
      percentages = terrain_hash.transform_values { |rating| ((rating / total_rating) * 100).to_i }

      puts "percentages: #{percentages}"
      
      passed_rules = []
    
      rules.each do |group, terrain_rules|
        all_terrains_passed = terrain_rules.all? do |terrain, range|
          percentage = percentages[terrain.to_s]
    
          if range.nil?
            true # Not required, so it passes
          else
            range.include?(percentage)
          end
        end
    
        passed_rules << group if all_terrains_passed
      end
    
      passed_rules
    end

end

end
# germanic: { lowland: 3..50, forest: 2..100, ocean: 0..85 },
terrain_hash = {
  # "lowland" => 30,
  # "forest" => 20,
  # "mountain" => 20,
  # "ocean" => 86,
  # "desert" => 11,
  # "town" => 1,
  # "peak" => 0
}
region = Emissary::NameGenererator.get_region_for_terrain(terrain_hash)
puts "region: #{region}"
generator = Emissary::NameGenererator.for_region(region)
puts "generator: #{generator.data}"

puts generator.get_name
