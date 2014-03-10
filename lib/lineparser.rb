#!/usr/bin/env ruby

# file: lineparser.rb

require 'line-tree'


class LineParser

  def initialize(patterns=[])

    @h = {

      String: lambda do |s, pattern|

        labels = []

        pattern.gsub!(/\+/,"\+")
        r = s.match(/#{pattern.gsub(/:\w+/) {|x| labels << x; '(\\w+)'}}/)

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

  end

  def parse(s)
    scan @tree_patterns, LineTree.new(s).to_a
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
        records << [found.first, params, x, children]
      else

        found = xpatterns.detect do |_, pattern| 
          params = @h[pattern.class.to_s.to_sym].call x.first, pattern
        end
        
        if found then
          children = nil
          children = scan(found[3..-1], x[1..-1]) if found.last.is_a? Array
          records << [found.first, params, x, children]
        end
      end
    end

    return records
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
  [:all, /#/]
]

lp = LineParser.new patterns
r = lp.parse lines
#=>  
[
  [:root, {":resources"=>"posts"}, ["resources: posts"], nil], 
  [:all, {:captures=>[]}, ["# winning"], nil], 
  [:all, {:captures=>[]}, ["#"], nil], 
  [:root, {":resource"=>"post"}, ["post", ["model", ["Post", ["orange 123"], ["fff"]]]],
    [[:resource, {}, ["model", ["Post", ["orange 123"], ["fff"]]],
      [[:model, {":class_name"=>"Post"}, ["Post", ["orange 123"], ["fff"]], 
        [[:model_class, {:captures=>["123"]}, ["orange 123"], nil]]
      ]]
    ]]
  ], 
  [:root, {":resource"=>"comments"}, ["comments", ["model", ["Comment", ["orange 576"], ["ggg"]]]],
    [[:resource, {}, ["model", ["Comment", ["orange 576"], ["ggg"]]], 
      [[:model, {":class_name"=>"Comment"}, ["Comment", ["orange 576"], ["ggg"]],
        [[:model_class, {:captures=>["576"]}, ["orange 576"], nil]]
      ]]
    ]]
  ]
] 

=end