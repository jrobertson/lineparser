#!/usr/bin/env ruby

# file: lineparser.rb

require 'line-tree'


class LineParser

  def initialize(patterns=[], lines=nil, ignore_blank_lines: true, debug: true)

    @ibl, @debug = ignore_blank_lines, debug
    @h = {

      String: lambda do |s, pattern|

        labels = []

        pattern.gsub!('+',"\\\\+")
        r = s.match(/#{pattern.gsub(/:\w+/) {|x| labels << x; '([^\\n]*)'}}/)

        if r then
          params = Hash[*labels.zip(r.captures).flatten(1)]
        end

      end,

      Regexp: lambda do |s, regex|

        r = s.match(regex)

        if r then
          h = {captures: r.captures}          
          r.names.inject(h) {|rn,x| rn.merge(x.to_sym => r[x])} if r.names
        end
      end
    }

    @patterns = patterns.select {|x| x.first == :all}

    hpatterns = {root: []}.merge patterns.inject({}){|r,x| r.merge(x[2] => x)}

    hpatterns.reverse_each do |k,v| 
      hpatterns[v.first] << v if hpatterns[v.first]
    end

    @tree_patterns =  hpatterns[:root].reverse

    parse lines if lines

  end

  def parse(s)

    puts 'inside parse()' if @debug
    a = scan @tree_patterns, LineTree.new(s, ignore_blank_lines: @ibl).to_a
    @h2 = build_hash a
    @a = a
    
  end

  def to_a
    @a
  end
  
  def to_h()
    @h2
  end

  def to_xml
    Rexle.new(xmlize(@a).inject([:root, '', {}]){|r,x| r << x}).xml if @a
  end

  private
  
  
  def build_hash(a)

    def filter(h2)
    
      h = {}
      puts 'h2: ' + h2.inspect if @debug
    
      h2.each do |k, v|
    
        puts 'v:' + v.inspect if @debug
    
          a3 = v.flat_map do |row| 

            a2 = []

            puts 'row: ' + row.inspect
            puts 'row[3]: ' + row[3].inspect

            if row[3] and row[3].any? then
              
              puts 'row[3][0][1]: ' + row[3][0][1].inspect if @debug
              
              if row[3][0][1].has_key? :captures then
                
                a2 = row[3].map {|x| x[2].first }

              else
                a2 = filter(row[3].group_by {|x| x.first })
              end
              
            else
              a2 = row[1].values.first
            end

            key = row[1].values.first            
            key ||= a2
            (key.empty? or key == a2) ? a2 : {key => a2}

          end
          
          h[k] = a3.length > 1 ? a3 : a3.first
    
      end
    
      return h
    end
    
    h3 = a.group_by {|x| x.first }
        
    filter(h3)    
    
  end 

  def join(lines, indent='')
    lines.map do |x|
      indent + (x.is_a?(Array) ? join(x, indent + '  ') : x)
    end.join("\n")
  end

  def scan(xpatterns, items)
    
    puts 'inside scan()' if @debug

    records = []

    while items.any? do

      x = items.shift

      params, context = nil, nil

      xpatterns = [xpatterns] unless xpatterns[0].is_a? Array

      found = @patterns.detect do |_, pattern| 
        params = @h[pattern.class.to_s.to_sym].call x.first, pattern
      end
      
      puts 'found: ' + found.inspect if @debug

      if found then

        children = nil
        children = scan(found.last, x[1..-1]) if found.last.is_a? Array
        records << [found[2], params, x, children]

      else

        puts 'xpatterns: ' + xpatterns.inspect if @debug
        
        found = xpatterns.detect do |_, pattern, id|
        
          puts 'found2: ' + found.inspect if @debug

          if pattern == :root then 

            found = @tree_patterns.detect do |_, pattern2, id|
              params = @h[pattern2.class.to_s.to_sym].call x.first, pattern2
              context = id if params
            end
            
            puts 'found3: ' + found.inspect if @debug
            
          else

            if @debug then
              puts '@h: ' + @h.inspect
              puts 'pattern: ' + pattern.inspect
              puts 'x.first: ' + x.first.inspect
            end
            
            params = @h[pattern.class.to_s.to_sym].call x.first, pattern
            puts 'params: ' + params.inspect if @debug
            context = id if params
          end
        end
        
        if found then

          children = nil
          children = scan(found[3..-1], x[1..-1]) if found.last.is_a? Array
          records << [context, params, x, children]
        end
      end
    end

    return records
  end

  def xmlize(rows)

    r = rows.map do |row|

      label, h, lines, children = row

      new_h = h.inject({}) do |r,k| 

        if k.first == :captures then

          k[-1].map.with_index.to_a.inject({}) do |r2,x|
            x[0] ? r.merge!(('captures' + x[-1].to_s).to_sym => x[0]) : r
          end
        else
          r.merge k[0][/\w+/] => k[-1]
        end
      end

      c = children ? xmlize(children) : []

      [label, join(lines), new_h, *c]
    end
   
    r
  end

end


=begin

Basic example:

lines =<<LINES
resources: posts
# winning
#
post
  model
    Post
      orange 123
      fff
comments
  model
    Comment
      orange 576
      ggg
LINES

patterns = [
  [:root, 'resources: :resources', :resources],
  [:root, ':resource', :resource],
  [:resource, 'model', :model],
  [:model, ':class_name', :model_class],
  [:model_class, /orange (\w+)/, :model_class_attribute],
  [:all, /#/, :comment]
]

lp = LineParser.new patterns
r = lp.parse lines
#=>  
 => [
  [:app_path, {":app_path"=>"/tmp"}, ["app_path: /tmp"], nil], 
  [:app, {":app"=>"blog"}, ["app: blog"], nil], 
  [:resources, {":resources"=>"posts"}, ["resources: posts"], ...
=end
