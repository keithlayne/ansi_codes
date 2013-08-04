require 'spec_helper'

describe AnsiCodes::State do
  it 'should not be instantiable' do
    expect{AnsiCodes::State.new('01', 'AL', 'Alabame')}.to raise_error(RuntimeError)
  end

  describe '#ansi_code' do
    it 'should return a two-digit string' do
      AnsiCodes::State.all.each do |state|
        state.ansi_code.should match(/^[0-9]{2}$/)
      end
    end
  end

  describe '#name' do
    it 'should return a string longer than 2 characters' do
      AnsiCodes::State.all.each do |state|
        state.name.should have_at_least(3).items
      end
    end

    it 'should return a proper name' do
      AnsiCodes::State.all.each do |state|
        state.name.should match(/^[A-Z].*[a-z]/)
      end
    end
  end

  describe '#abbreviation' do
    it 'should return a two-character uppercase string' do
      AnsiCodes::State.all.each do |state|
        state.abbreviation.should match(/^[A-Z]{2}$/)
      end
    end
  end

  describe '#counties' do
    it 'should return an array of AnsiCodes::County' do
      counties = AnsiCodes::State.all.first.counties
      counties.should be_an(Array)
      counties.each do |county|
        county.should be_a(AnsiCodes::County)
      end
    end
  end

  describe 'all' do
    it 'should return 57 elements' do
      AnsiCodes::State.all.should have(57).items
    end

    it 'should return an array' do
      AnsiCodes::State.all.should be_an(Array)
    end

    it 'should contain AnsiCodes::State instances' do
      AnsiCodes::State.all.each do |state|
        state.should be_an_instance_of(AnsiCodes::State)
      end
    end
  end

  describe 'find' do
    it 'should raise ArgumentError with no arguments' do
      expect{AnsiCodes::State.find}.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError with more than one argument' do
      expect{AnsiCodes::State.find 1, 2}.to raise_error(ArgumentError)
    end

    it 'should accept an integer argument' do
      expect{AnsiCodes::State.find 12}.not_to raise_error
    end

    it 'should accept a string argument' do
      expect{AnsiCodes::State.find '12'}.not_to raise_error
    end

    it 'should return Alabama with lookup = 1' do
      AnsiCodes::State.find(1).name.should == 'Alabama'
    end

    it 'should return Alabama with lookup = "01"' do
      AnsiCodes::State.find('01').name.should == 'Alabama'
    end

    it 'should be case-insensitive' do
      AnsiCodes::State.find('wi').should == AnsiCodes::State.find('WI')
      AnsiCodes::State.find('NEW JERSEY').should == AnsiCodes::State.find('nEw JeRsEy')
    end

    it 'should raise a RuntimeError if no match is found' do
      expect{AnsiCodes::State.find 'chimichanga'}.to raise_error(RuntimeError)
    end

    it 'should yield the result if a block is given' do
      state = AnsiCodes::State.find 'New York'
      expect { |b| AnsiCodes::State.find('New York', &b) }.to yield_with_args(state)
    end

    it 'should return identical objects with the same parameters' do
      AnsiCodes::State.find('01').should eql(AnsiCodes::State.find('01'))
    end

    it 'should return identical objects when lookup result is same' do
      AnsiCodes::State.find('AL').should eql(AnsiCodes::State.find('01'))
    end
  end

end
