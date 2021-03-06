require 'spec_helper'
include Capybara::DSL

describe Gatling do

  after :all do
    config_clean_up
  end

  let(:actual_image)      { mock("Gatling::Image") }
  let(:expected_image)    { mock("Gatling::Image") }
  let(:comparison)        { mock("Gatling::Comparison") }
  let(:element)           { mock("Gatling::CaptureElement") }

  
  describe 'comparison' do
    before :each do
      Gatling::ImageFromFile.stub!(:new).and_return(expected_image)
      Gatling::ImageFromElement.stub!(:new).and_return(actual_image)
      Gatling::Comparison.stub!(:new).and_return(comparison)
      expected_image.should_receive(:file_name).and_return('expected_image.png')
    end

    it 'will return true if the images are identical' do
        comparison.stub!(:matches?).and_return(true)
        File.stub!(:exists?).and_return(true)

        subject.matches?("expected_image.png", @element).should be_true
    end
  end  


  describe 'saving images' do
    before :each do
      @image_class_mock = mock(Gatling::Image)
    end


    it "#save_image_as_diff" do
      @image_class_mock.should_receive(:save).with(:diff).and_return(@ref_path)
      @image_class_mock.should_receive(:file_name).at_least(:once).and_return("some_name")

      expect {subject.save_image_as_diff(@image_class_mock)}.to raise_error
    end

    it "#save_image_as_candidate" do
      @image_class_mock.should_receive(:save).with(:candidate).and_return(@ref_path)
      @image_class_mock.should_receive(:file_name).at_least(:once).and_return("some_name")
      @image_class_mock.should_receive(:path).and_return(@path)
      expect {subject.save_image_as_candidate(@image_class_mock)}.to raise_error
    end

    describe "#save_image_as_reference" do

      let(:image) {mock('image.png')}
      let(:reference_image) {Gatling::ImageFromElement.stub(:new).and_return(image)}
      let(:comparison) {mock("comparison")}

      before :each do
        Gatling.stub!(:compare_until_match).and_return(comparison)
      end

    end
  end  

  describe "#compare_until_match" do

    before :each do
      Gatling::ImageFromElement.stub!(:new).and_return(actual_image)
      Gatling::ImageFromFile.stub!(:new).and_return(expected_image)
      Gatling::Comparison.stub!(:new).and_return(comparison)

      expected_image.should_receive(:file_name).at_least(:once).and_return('expected_image.png')
    end

    it "should try match for a specified amount of times" do
      comparison.should_receive(:matches?).exactly(3).times.and_return(false)
      Gatling.compare_until_match(@element, expected_image, 3, 0.1)
    end

    it "should pass after a few tries if match is found" do
      comparison.should_receive(:matches?).exactly(1).times.and_return(true)
      Gatling.compare_until_match(@element, expected_image, 3, 0.1)
    end

  end
end