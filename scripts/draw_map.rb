require 'json'
require 'optparse'
require_relative '../models/game_state'
require_relative '../models/settlement'
require 'emissary-maps'

class DrawMap

  attr_accessor :state

  # load gamestate and draw map as svg
  def initialize(gamefile, mapfile, hexsize=10)

    # create an empty gamestate
    @state = Emissary::GameState.load(gamefile)

    File.open(mapfile, 'w') do | file |
      size = @state.size
      self.to_svg @state, size, file, hexsize
    end

  end

  def is_trade_node?(map, coords)
      hex = getHex(map, coords.x, coords.y)
      hex.trade_node 
   end

   def getHex(map, x, y)
      map["#{x},#{y}".to_sym]
   end

  # output as svg
   def to_svg(state, size, io, hexsize=10)

      terrain_colors = {
         peak: 'dimgray',
         ocean: '#3D59AB', 
         mountain: 'slategray',
         lowland: '#65b240',
         forest: '#316e44',
         desert: 'goldenrod',
         town: 'Sienna',
         city: 'Sienna'
      }

      hex_b = 2*Math.sin( 60*(Math::PI/180) )*hexsize
      xoffset = (hex_b/2).round + Emissary::MapUtils::hex_pos(0, (size/2).round, hexsize, 0, 0)[:x].abs
      yoffset = hexsize*1.25
      canvassize_x = ((size+1) * hex_b).round
      canvassize_y = hexsize * 1.5 * (size + 2)

      io.print "<?xml version=\"1.0\"?>"
      io.print "<svg width=\"#{canvassize_x}\" height=\"#{canvassize_y}\""
      io.print " viewPort=\"0 0 #{canvassize_x} #{canvassize_y}\" version=\"1.1\""
      io.print " xmlns=\"http://www.w3.org/2000/svg\">\n"
      io.print "<rect width=\"#{canvassize_x}\" height=\"#{canvassize_y}\" fill=\"#3D59AB\"/>"

      # create icons
      io.print "<symbol id=\"trade\" width=\"#{hexsize}\" height=\"#{hexsize}\" viewBox=\"0 0 512 512\">"
      io.print '<path xmlns="http://www.w3.org/2000/svg" d="M203.97 23l-18.032 4.844 11.656 43.468c-25.837 8.076-50.32 21.653-71.594 40.75L94.53 80.594l-13.218 13.22 31.376 31.374c-19.467 21.125-33.414 45.53-41.813 71.343l-42.313-11.343-4.843 18.063 42.25 11.313c-6.057 27.3-6.157 55.656-.345 83L23.72 308.78l4.843 18.064 41.812-11.22c6.693 21.225 17.114 41.525 31.25 59.876l-29.97 52.688-16.81 29.593 29.56-16.842 52.657-29.97c18.41 14.216 38.784 24.69 60.094 31.407l-11.22 41.844 18.033 4.81 11.218-41.905c27.345 5.808 55.698 5.686 83-.375l11.312 42.28 18.063-4.81-11.344-42.376c25.812-8.4 50.217-22.315 71.342-41.78l31.375 31.373 13.22-13.218-31.47-31.47c19.09-21.266 32.643-45.738 40.72-71.563l43.53 11.657 4.813-18.063-43.625-11.686c5.68-27.044 5.576-55.06-.344-82.063l43.97-11.78-4.813-18.063L440.908 197c-6.73-20.866-17.08-40.79-31.032-58.844l29.97-52.656 16.842-29.563-29.593 16.844-52.656 29.97c-17.998-13.875-37.874-24.198-58.657-30.906l11.783-44L309.5 23l-11.78 43.97c-27-5.925-55.02-6.05-82.064-.376L203.97 23zm201.56 85L297.25 298.313l-.75.437-40.844-40.875-148.72 148.72-2.186 1.25 109.125-191.75 41.78 41.78L405.532 108zm-149.686 10.594c21.858 0 43.717 5.166 63.594 15.47l-116.625 66.342-2.22 1.28-1.28 2.22-66.25 116.406c-26.942-52.04-18.616-117.603 25.03-161.25 26.99-26.988 62.38-40.468 97.75-40.468zm122.72 74.594c26.994 52.054 18.67 117.672-25.002 161.343-43.66 43.662-109.263 52.005-161.312 25.033l116.438-66.282 2.25-1.25 1.25-2.25 66.375-116.592z" />'
      io.print '</symbol>'

      io.print "<symbol id=\"town\" width=\"#{hexsize}\" height=\"#{hexsize}\" viewBox=\"0 0 512 512\">"
      io.print '<path xmlns="http://www.w3.org/2000/svg" d="M109.902 35.87l-71.14 59.284h142.28l-71.14-59.285zm288 32l-71.14 59.284h142.28l-71.14-59.285zM228.73 84.403l-108.9 90.75h217.8l-108.9-90.75zm-173.828 28.75v62h36.81l73.19-60.992v-1.008h-110zm23 14h16v18h-16v-18zm265 18v10.963l23 19.166v-16.13h16v18h-13.756l.104.087 19.098 15.914h-44.446v14h78v-39h18v39h14v-62h-110zm-194.345 48v20.08l24.095-20.08h-24.095zm28.158 0l105.1 87.582 27.087-22.574v-65.008H176.715zm74.683 14h35.735v34h-35.735v-34zm-76.714 7.74L30.37 335.153H319l-144.314-120.26zm198.046 13.51l-76.857 64.047 32.043 26.704H481.63l-108.9-90.75zm-23.214 108.75l.103.086 19.095 15.914h-72.248v77.467h60.435v-63.466h50v63.467h46v-93.466H349.516zm-278.614 16V476.13h126v-76.976h50v76.977h31.565V353.155H70.902zm30 30h50v50h-50v-50z" />'
      io.print '</symbol>'

      io.print "<symbol id=\"city\" width=\"#{hexsize}\" height=\"#{hexsize}\" viewBox=\"0 0 512 512\">"
      io.print '<path xmlns="http://www.w3.org/2000/svg" d="M255.95 27.11L180.6 107.614l150.7 1.168-75.35-81.674h-.003zM25 109.895v68.01l19.412 25.99h71.06l19.528-26v-68h-14v15.995h-18v-15.994H89v15.995H71v-15.994H57v15.995H39v-15.994H25zm352 0v68l19.527 26h71.06L487 177.906v-68.01h-14v15.995h-18v-15.994h-14v15.995h-18v-15.994h-14v15.995h-18v-15.994h-14zm-176 15.877V260.89h110V126.63l-110-.857zm55 20.118c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zM41 221.897V484.89h78V221.897H41zm352 0V484.89h78V221.897h-78zM56 241.89c4 0 8 4 8 12v32H48v-32c0-8 4-12 8-12zm400 0c4 0 8 4 8 12v32h-16v-32c0-8 4-12 8-12zm-303 37v23h-16v183h87v-55c0-24 16-36 32-36s32 12 32 36v55h87v-183h-16v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14v23h-18v-23h-14zm-49 43c4 0 8 4 8 12v32H96v-32c0-8 4-12 8-12zm72 0c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zm80 0c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zm80 0c8 0 16 4 16 12v32h-32v-32c0-8 8-12 16-12zm72 0c4 0 8 4 8 12v32h-16v-32c0-8 4-12 8-12zm-352 64c4 0 8 4 8 12v32H48v-32c0-8 4-12 8-12zm400 0c4 0 8 4 8 12v32h-16v-32c0-8 4-12 8-12z"/>'
      io.print '</symbol>'

      # assign each trade node a color
      colors = ['mediumvioletred', 'indigo', 'darkviolet', 'midnightblue', 'saddlebrown', 'chocolate', 'maroon', 'deeppink'].shuffle
      trade_node_colors = Hash.new
      @state.map.each { | key, hex |
         if is_trade_node? @state.map, hex
            trade_node_colors[key] = colors.pop
         end
      }

      @state.map.each { | key, hex |

         terrain = hex.terrain

         terrain_color = terrain_colors[terrain.to_sym]
         if terrain == "ocean"
            if is_trade_node? @state.map, hex
               # terrain_color = hex.tradenode
               # terrain_color = "blueviolet"
               terrain_color = trade_node_colors[key]
            end
         end

         pos = Emissary::MapUtils::hex_pos(hex.x, hex.y, hexsize, xoffset, yoffset)
         hexsizes = Emissary::MapUtils::hexsizes(hexsize)
         hex_points = Emissary::MapUtils::hex_points(pos[:x], pos[:y], hexsize)

         io.print "<polygon points=\""
         hex_points.each { | hex_point |
            io.print "#{hex_point[:x].round(2)},#{hex_point[:y].round(2)} "
         }
         
         stroke = "black"
         stroke_width= 0.1
         # stroke = "transparent"
         # stroke_width= 0
         
         # show the ocean in trade node colors
         # if !is_trade_node?(@state.map, hex) and hex.trade
         #    terrain_color = trade_node_colors["#{hex.trade.x},#{hex.trade.y}".to_sym]
         # end

         io.print "\" fill=\"#{terrain_color}\" stroke=\"#{stroke}\" stroke-width=\"#{stroke_width}\" />"

         x = pos[:x].to_f - (hexsize.to_f/2).to_f
         y = pos[:y].to_f - (hexsize.to_f/2).to_f
         text_color = 'black';
         if terrain == "town"
            text_color = 'white';
            io.print "<use href=\"#town\" x=\"#{x.round(2)}\"  y=\"#{y.round(2)}\" fill=\"white\" style=\"opacity:1.0\" />"
         elsif terrain == "city"
            text_color = 'white';
            io.print "<use href=\"#city\" x=\"#{x.round(2)}\"  y=\"#{y.round(2)}\" fill=\"white\" style=\"opacity:1.0\" />"
         elsif terrain == "ocean" and is_trade_node? @state.map, hex
            io.print "<use href=\"#trade\" x=\"#{x.round(2)}\"  y=\"#{y.round(2)}\" fill=\"white\" style=\"opacity:0.8\" />"
         end
         
         if terrain == "town"  or terrain == "city"
            io.print "<text font-size=\"2px\" x=\"#{hex_points[0][:x]}\" y=\"#{(hex_points[2][:y] + hex_points[3][:y]) / 2}\" width=\"#{hex_points[0][:x] - hex_points[2][:x]}\" fill=\"#{text_color}\" text-anchor=\"middle\">#{hex.x},#{hex.y}</text>"
         end
      }
      
      # iterate again and add all borders AFTER hexs
      @state.map.each { | key, hex |
         if hex.is_a?(Emissary::Settlement)
            if hex.borders    
               
               border_lines = Array.new
               hex.borders.each { |border|
                  border_area = @state.getHexFromCoord(border)
                  border_center = Emissary::MapUtils::hex_pos(border[:x], border[:y], hexsize, xoffset, yoffset)
                  border_points = Emissary::MapUtils::hex_points(border_center[:x], border_center[:y], hexsize)
                  border_area_province = border_area&.province&.name
                  border_area_province = border_area.name if border_area.is_a?(Emissary::Settlement)
                 

                  adjacent_coords = Emissary::MapUtils.adjacent(border, @state.map.size)                  
                  adjacent_coords.each { |adjacent_coord|
                     adjacent_hex = @state.getHexFromCoord(adjacent_coord)
                     if adjacent_hex 
                        adjacent_hex_province = adjacent_hex&.province&.name
                        adjacent_hex_province = adjacent_hex.name if adjacent_hex.is_a?(Emissary::Settlement)
                        
                        if adjacent_hex and adjacent_hex_province != border_area_province

                           adjacent_center = Emissary::MapUtils::hex_pos(adjacent_hex.x, adjacent_hex.y, hexsize, xoffset, yoffset)
                           adjacent_points = Emissary::MapUtils::hex_points(adjacent_center[:x], adjacent_center[:y], hexsize)                        
                           common_points = adjacent_points.select { |point|
                              border_points.any? { |border_point| 
                                 (point[:x] - border_point[:x]).abs < 0.1 && 
                                 (point[:y] - border_point[:y]).abs < 0.1 
                              }
                           }
                           border_lines.push(common_points) if common_points.length == 2                                                   
                        end
                     end
                  }
               }

               border_lines.each do |border_points|
                  io.print "<line x1=\"#{border_points[0][:x].round(2)}\" y1=\"#{border_points[0][:y].round(2)}\" "
                  io.print "x2=\"#{border_points[1][:x].round(2)}\" y2=\"#{border_points[1][:y].round(2)}\" "
                  io.print "stroke=\"#000000CC\" stroke-width=\"1\" stroke-dasharray=\"2,3\" />"
               end
            end
                                                  
            if hex.coast            
               # puts "Hex at #{hex.x},#{hex.y} has coast: #{hex.coast}"
            end
         end
         

      }

      # town and city labels
      @state.map.each { | key, hex |

         if hex.terrain == "city" or hex.terrain == "town" or
            (hex.terrain == "ocean" and is_trade_node? @state.map, hex)

            pos = Emissary::MapUtils::hex_pos(hex.x, hex.y, hexsize, xoffset, yoffset)
            hexsizes = Emissary::MapUtils::hexsizes(hexsize)
            hex_points = Emissary::MapUtils::hex_points(pos[:x], pos[:y], hexsize)

            x = hex_points[2][:x].round(2)
            y = hex_points[2][:y].round(2)
            color = "black"

            font_size = '20px'
            font_size = '14px' if hex.terrain == "town"

            text = hex.name
            # text = hex.shortcut_help
            text = hex.trade_node.name if text.nil?
            io.print "<text font-size=\"#{font_size}\" x=\"#{x}\" y=\"#{y}\" fill=\"#{color}\">#{text}</text>"

         end
      }

      io.print "</svg>"
   end

end


# parse command line options
options = Hash.new
OptionParser.new do | opts |
   opts.banner = "Usage: draw_map.rb [options]"

  opts.on("-gGAME", "--gamefile=GAME", "File to read game from") do |n|
     options[:gamefile] = n
  end

  opts.on("-mFILE", "--map=FILE", "Map file to write") do |n|
     options[:mapfile] = n
  end

  opts.on("-hHEXSIZE", "--hexsize=HEXSIZE", "Size in pixels for one hex") do |n|
     options[:hexsize] = n.to_i
  end
end.parse!

ng = DrawMap.new options[:gamefile], options[:mapfile], options[:hexsize]


# bundle exec ruby draw_map.rb -g game.yaml -m world.svg -h 6