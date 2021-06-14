require 'spec_helper'

RSpec.describe  PetStore, type: :module do
  describe "PetStore#order" do

    context 'no animals requested as input' do
      it "should return nil when no animals are ordered" do
        result = PetStore.order(nil)
        expect(result).to be nil
      end
    end

    context 'valid animals are provided as input' do
      it "accepts lower case animal identifier" do
        result = PetStore.order(['r'])
        expect(result).to eq (['B1'])
      end

      it "should return 'B1' when one rat only is ordered" do
        result = PetStore.order(['R'])
        expect(result).to eq (['B1'])
      end

      it "should return 'B1' when one hedgehog only is ordered" do
        result = PetStore.order(['H'])
        expect(result).to eq (['B1'])
      end

      it "should return 'B2' when one mongoose only is ordered" do
        result = PetStore.order(['M'])
        expect(result).to eq (['B2'])
      end
      
      it "should return 'B3' when one snake only is ordered" do
        result = PetStore.order(['S'])
        expect(result).to eq (['B3'])
      end

      it "should return 'B3' when one rat and two hedgehogs are ordered" do
        result = PetStore.order(['R','H','H'])
        expect(result).to eq (['B3'])
      end

      it "should return a 'B2' & B3' when one snake and one mongoose are ordered" do
        result = PetStore.order(['S','M'])
        expect(result).to match_array ['B3','B2']
      end

      it "should return two 'B3s' when one snake, one mongoose, one rat and a hedgehog are ordered" do
        result = PetStore.order(['S','H','R','M'])
        expect(result).to match_array ['B3','B3']
      end

      it "should return a 'B1 & B3' when one rat one hedgehog and a snake are ordered" do
        result = PetStore.order(['R','H','S'])
        expect(result).to match_array ['B1','B3']
      end

      it "should return two 'B3s' when two mongeese, one rat and a snake are ordered" do
        result = PetStore.order(['M','R','M','S'])
        expect(result).to match_array ['B3','B3']
      end

      it "should return a 'B3' when four rats are ordered" do
        result = PetStore.order(['R','R','R','R'])
        expect(result).to match_array ['B3']
      end      
      
      it "should return two 'B3's when three rats, a mongoose and a snake are ordered" do
        result = PetStore.order(['R','R','R','M','S'])
        expect(result).to match_array ['B3','B3']
      end 
    end

    context 'at least one invalid animal is requested' do
      it "should return the error advising animal is not available" do
        result = PetStore.order(['R','H','K'])
        expect(result).to match_array ['one or more animals requested are not available']
      end
    end

    context 'animal is valid BUT no box exists for animals size' do
      let(:available_items) do 
        { 'R' => 400, 'H' => 400, 'M' => 800, 'S' => 1200, 'X' => 4000 }
      end
      before { allow(PetStore).to receive(:available_items).and_return(available_items)}

      it "should return error advising there is no box for the size of animal requested" do
        result = PetStore.order(['R','H','X'])
        expect(result).to match_array ['no box large enough to contain animal']
      end

      context 'and one animal does not exist' do
        it "should return error advising there is no box for the size of animal requested" do
          result = PetStore.order(['R','H','X','Y'])
          expect(result).to match_array ['no box large enough to contain animal','one or more animals requested are not available']
        end
      end
    end
  end
end