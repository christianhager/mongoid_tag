require 'spec_helper'


class Product
  include Mongoid::Document
  include Mongoid::Tag
  
  tag :tags
  tag :shapes
end

class ProductWithCategory
  include Mongoid::Document
  include Mongoid::Tag
  
  belongs_to :category
  
  tag :tags, :meta_in => :category
end

class Category
  include Mongoid::Document
  include Mongoid::Tag::Meta
  
  has_many :products
  
  tagmeta_for :tags
end


describe Mongoid::Tag do
  
  describe "tagged object" do
    before(:each) do
      @p1 = Product.new
      @p2 = Product.new
    end
    
    it "should create a tags_array" do
      @p1.tags = "new, blue"
      @p1.tags_array.should == ["new", "blue"]
    end
    
    it "should create a string from array" do
      @p1.tags_array = ["new", "blue"]
      @p1.tags.should == "new, blue"
    end
    
    it "should wash away whitespace" do
      @p1.tags = "new      ,       blue"
      @p1.tags_array.should == ["new", "blue"]
      @p1.tags_array = ["new     ", "     blue"]
      @p1.tags.should == "new, blue"
    end
    
    it "should work with other name than tags" do
      @p1.tags = "new, blue"
      @p1.tags_array.should == ["new", "blue"]
      @p1.shapes = "round, square"
      @p1.shapes_array.should == ["round", "square"]
    end
  end
  
  describe "scopes" do
    before(:each) do
      @p1 = Product.create
      @p2 = Product.create
    end
    
    it "finds all models tagged with one or more tags" do
      @p1.tags = "new, green"
      @p2.tags = "new, blue"
      @p1.save; @p2.save;
      Product.with_any_tags("new").to_a.should == [@p1, @p2]
      Product.with_any_tags("green").to_a.should == [@p1]
      Product.with_any_tags("blue").to_a.should == [@p2]
      Product.with_any_tags(["new", "blue"]).to_a.should == [@p1, @p2]
    end
    
    it "finds all models tagged with one or more tags" do
      @p1.tags = "new, green"
      @p2.tags = "new, blue"
      @p1.save; @p2.save;
      Product.with_all_tags("new").to_a.should == [@p1, @p2]
      Product.with_all_tags("green").to_a.should == [@p1]
      Product.with_all_tags("blue").to_a.should == [@p2]
      Product.with_all_tags(["new", "blue"]).to_a.should == [@p2]
    end
    
    it "fonds all models not tagged with one or more tags" do
      @p1.tags = "new, green"
      @p2.tags = "new, blue"
      @p1.save; @p2.save;
      Product.without_tags("new").to_a.should == []
      Product.without_tags("green").to_a.should == [@p2]
      Product.without_tags("blue").to_a.should == [@p1]
      Product.without_tags(["new", "blue"]).to_a.should == []
    end
  end
end


describe Mongoid::Tag::Meta do
  
  before(:each) do
    @c = Category.create
    @p = ProductWithCategory.create(:category => @c)
    @p2 = ProductWithCategory.create(:category => @c)
  end
  
  it "should increase count when a a child is tagged" do
    @p.update_attributes(:tags => "new, blue")
    @c.tags_with_weight.should == [["new", 1], ["blue", 1]]
    @p2.update_attributes(:tags => "blue")
    @c.tags_with_weight.should == [["new", 1], ["blue", 2]]
    @p2.update_attributes(:tags => "blue, green")
    @c.tags_with_weight.should == [["new", 1], ["blue", 2], ["green", 1]]
  end
  
  it "should decrease count when a tag is removed" do
    @p.update_attributes(:tags => "new, blue")
    @c.tags_with_weight.should == [["new", 1], ["blue", 1]]
    @p.update_attributes(:tags => "new")
    @c.tags_with_weight.should == [["new", 1], ["blue", 0]]
  end
  
  it "should decrease count when a child is destroyed" do
    @p.update_attributes(:tags => "new, blue")
    @c.tags_with_weight.should == [["new", 1], ["blue", 1]]
    @p.destroy
    Category.find(@c.id).tags_with_weight.should == [["new", 0], ["blue", 0]]
  end
  
  it "can get the meta for all tags" do
    @c.add_tag("cheap", {:color => "red"})
    @c.tags_with_meta.should == [["cheap", {:color=>"red", :count=>1}]]
    @c.add_tag("expensive", {:color => "green"})
    @c.add_tag("medium", {:color => "#ddd"}) 
    @c.tags_with_meta.should == [["cheap", {:color=>"red", :count=>1}], ["expensive", {:color=>"green", :count=>1}], ["medium", {:color=>"#ddd", :count=>1}]]
  end
  
  it "can update meta for a tag" do
    @c.add_tag("cheap", {:color => "red"})
    @c.tags_with_meta.should == [["cheap", {:color=>"red", :count=>1}]]
    @c.add_tag("cheap", {:color => "blue"})
    @c.tags_with_meta.should == [["cheap", {:color=>"blue", :count=>1}]]
  end
end