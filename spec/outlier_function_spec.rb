# frozen_string_literal: true

require_relative '../run.rb'

RSpec.describe "get_outliers_from_number_array" do
    it "is not returning outliers on requesting 0 outliers" do
        expect(get_outliers_from_number_array([1, 17, 8, 8, -1, 0.5, 100], 0)).to eq []
    end
    it "is returning all as outliers on requesting 100% outliers on arrays with an even element number" do
        array = [1, 17, 8, 8, -1, 0.5, 100, 1001]
        returned = get_outliers_from_number_array(array, 100)
        expect(returned.length).to eq array.length
        array.each do |number|
            expect(returned.count(number)).to eq array.count(number)
        end
    end
    it "is returning half as outliers on requesting 50% outliers on array where length allows this" do
        array = [1, 17, 8, 8, -1, 0.5, 100, 1001]
        returned = get_outliers_from_number_array(array, 50)
        expect(returned.length).to eq array.length / 2
    end
end
