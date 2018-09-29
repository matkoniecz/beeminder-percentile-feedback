require_relative '../processing.rb'

RSpec.describe "PercentileCounter" do
  it "calculates percentile of the largest element to be 100" do
    expect(get_percentile(1819, [-100, 88, 33, 1818, 9, 1819])).to eq 100
  end

  it "calculates percentile below the smallest element to be 0" do
    expect(get_percentile(-30393, [-100, 88, 33, 1818, 9, 1819])).to eq 0
  end

  it "calculates percentile of the 1st element of 10 to be 10" do
    expect(get_percentile(1, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 10
  end

  it "calculates percentile of the 2nd element of 10 to be 20" do
    expect(get_percentile(2, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 20
  end

  it "calculates percentile of the 3rd element of 10 to be 30" do
    expect(get_percentile(3, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 30
  end

  it "calculates percentile of the 4th element of 10 to be 40" do
    expect(get_percentile(4, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 40
  end

  it "calculates percentile of the 5th element of 10 to be 50" do
    expect(get_percentile(5, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 50
  end

  it "calculates percentile of the 6th element of 10 to be 60" do
    expect(get_percentile(6, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 60
  end

  it "calculates percentile of the 7th element of 10 to be 70" do
    expect(get_percentile(7, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 70
  end

  it "calculates percentile of the 8th element of 10 to be 80" do
    expect(get_percentile(8, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 80
  end

  it "calculates percentile of the 9th element of 10 to be 90" do
    expect(get_percentile(9, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 90
  end

  it "calculates percentile of the 10th element of 10 to be 100" do
    expect(get_percentile(10, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).to eq 100
  end
end
