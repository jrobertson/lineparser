# Introducing the Lineparser gem

    require 'lineparser'

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

output observed:

<pre>
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
</pre>


## Resources

* [jrobertson/lineparser](https://github.com/jrobertson/lineparser)

lineparser linetree parser configuration
