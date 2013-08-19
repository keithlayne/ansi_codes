require 'spec_helper'

describe AnsiCodes::County do

  it 'should not be instantiable' do
    expect { AnsiCodes::County.new('01', '001', 'Autauga County') }.to raise_error(NoMethodError)
  end

  it 'should not be modifiable' do
    expect { AnsiCodes::County.find(1, 1).name = 'county' }.to raise_error(NoMethodError)
  end

  describe '#county_ansi' do
    it 'should return a three-digit string' do
      AnsiCodes::County.all.each do |county|
        county.county_ansi.should match(/^[0-9]{3}$/)
      end
    end

    it 'should return the same county when looked up by result' do
      AnsiCodes::County.all.each do |county|
        AnsiCodes::County.find(county.state_ansi, county.county_ansi).should be(county)
      end
    end
  end

  describe '#name' do
    before(:each) { @names = AnsiCodes::County.all.map(&:name) }

    it 'should return a string' do
      @names.each { |name| name.should be_a(String) }
    end

    it 'should be at least 4 characters long' do
      @names.each { |name| name.should have_at_least(4).items }
    end

    it 'should return the same county when looked up by result' do
      AnsiCodes::County.all.each do |county|
        AnsiCodes::County.find(county.state, county.name).should be(county)
      end
    end
  end

  describe '#short_name' do
    before(:each) { @short_names = AnsiCodes::County.all.map(&:short_name) }

    it 'should return a string' do
      @short_names.each { |short_name| short_name.should be_a(String) }
    end

    it 'should be no longer than #name' do
      AnsiCodes::County.all.each do |county|
        county.short_name.should have_at_most(county.name.size).characters
      end
    end
  end

  describe '#designation' do
    before(:each) { @designations = AnsiCodes::County.all.map(&:designation) }

    it 'should return a string' do
      @designations.each { |designation| designation.should be_a(String) }
    end

    it 'should be shorter than #name' do
      AnsiCodes::County.all.each do |county|
        county.designation.should have_at_most(county.name.size - 1).characters
      end
    end
  end

  describe '#state_ansi' do
    before(:each) { @states = AnsiCodes::County.all.map(&:state_ansi) }

    it 'should return an three-digit string' do
      @states.each do |state|
        AnsiCodes::State.find(state).should be_an(AnsiCodes::State)
      end
    end
  end

  describe '.all' do
    it 'should return 3235 elements' do
      AnsiCodes::County.all.should have(3235).items
    end

    it 'should return an array of AnsiCodes::County' do
      AnsiCodes::County.all.tap do |counties|
        counties.should be_an(Array)
        counties.each { |county| county.should be_an_instance_of(AnsiCodes::County) }
      end
    end
  end

  describe '.find' do
    it 'should accept a string as first param' do
      expect { AnsiCodes::County.find '01', '001' }.not_to raise_error
    end

    it 'should accept an integer as first param' do
      expect { AnsiCodes::County.find 1, '001' }.not_to raise_error
    end

    it 'should accept an AnsiCodes::State as first param' do
      expect { AnsiCodes::County.find AnsiCodes::State.all.first, '001' }.not_to raise_error
    end

    it 'should accept a string as second param' do
      expect { AnsiCodes::County.find 1, '001' }.not_to raise_error
    end

    it 'should accept an integer as second param' do
      expect { AnsiCodes::County.find 1, 1 }.not_to raise_error
    end

    it 'should raise an ArgumentError on any other type as second param' do
      expect { AnsiCodes::County.find 1, nil }.to raise_error(ArgumentError)
      expect { AnsiCodes::County.find 1, 1.0 }.to raise_error(ArgumentError)
      expect { AnsiCodes::County.find 1, /really?/ }.to raise_error(ArgumentError)
      expect { AnsiCodes::County.find 1, {} }.to raise_error(ArgumentError)
      expect { AnsiCodes::County.find 1, [] }.to raise_error(ArgumentError)
    end

    it 'should yield the result if a block is given' do
      county = AnsiCodes::County.find 'Virginia', 'Norfolk city'
      expect { |b| AnsiCodes::County.find('Virginia', 'Norfolk city', &b) }.to yield_with_args(county)
    end

    it 'should raise an exception if no county is found' do
      expect { AnsiCodes::County.find 45, 1000 }.to raise_error
    end
  end

  if defined? ActiveModel
    before { @model = AnsiCodes::State.all.first.dup }
    it_behaves_like 'ActiveModel'
  end
end
