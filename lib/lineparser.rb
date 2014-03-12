#!/usr/bin/env ruby

# file: lineparser.rb

require 'line-tree'


class LineParser

  def initialize(patterns=[], lines=nil)

    @h = {

      String: lambda do |s, pattern|

        labels = []

        pattern.gsub!('+',"\\\\+")
        r = s.match(/#{pattern.gsub(/:\w+/) {|x| labels << x; '(\\S+)'}}/)

        if r then
          params = Hash[*labels.zip(r.captures).flatten(1)]
        end

      end,

      Regexp: lambda do |s, regex|

        r = s.match(regex)

        if r then
          {captures: r.captures}
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
    @a = scan @tree_patterns, LineTree.new(s).to_a
  end

  def to_xml
    Rexle.new(xmlize(@a)).xml if @a
  end

  private

  def scan(xpatterns, items)

    records = []

    while items.any? do

      x = items.shift
      params = nil

      xpatterns = [xpatterns] unless xpatterns[0].is_a? Array

      found = @patterns.detect do |_, pattern| 
        params = @h[pattern.class.to_s.to_sym].call x.first, pattern
      end

      if found then
        children = nil
        children = scan(found.last, x[1..-1]) if found.last.is_a? Array
        records << [found[2], params, x, children]
      else

        found = xpatterns.detect do |_, pattern| 
          params = @h[pattern.class.to_s.to_sym].call x.first, pattern
        end
        
        if found then
          children = nil
          children = scan(found[3..-1], x[1..-1]) if found.last.is_a? Array
          records << [found[2], params, x, children]
        end
      end
    end

    return records
  end

  def xmlize(rows)

    r = rows.map do |label, h, lines, children|

      new_h = h.inject({}) do |r,k| 

        if k.first == :captures then

          k[-1].map.with_index.to_a.inject({}) do |r2,x|
            r.merge! ('captures' + x[-1].to_s).to_sym => x[0] 
          end
        else
          r.merge k[0][/\w+/] => k[-1]
        end
      end

      xml_children = children ? xmlize(children) : nil
      [label, join(lines), new_h, xml_children]
    end
   
    r.flatten(1)
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