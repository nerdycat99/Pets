module PetStore
  def self.order(animals)
    return if animals.nil?
    current_order = Order.new()

    animals.each do |animal|
      animal = animal.capitalize()
      if available_items[animal]
        current_order.add(Animal.new(available_items[animal], animal))
      else
        current_order.add_error('one or more animals requested are not available')
      end
    end
    output = []
    current_order.required_boxes.used_boxes.each { |box| output << box.type }
    return current_order.errors unless current_order.errors.empty?
    output
  end

  def self.available_items
    available_items = { 'R' => 400, 'H' => 400, 'M' => 800, 'S' => 1200 }
  end
end


class Order
  attr_accessor :animals, :errors

  def initialize(animals=[])
    @animals = animals
    @errors = []
  end

  def add_error(message)
    errors << message
  end

  def add(animal)
    self.animals << animal
  end

  def required_boxes
    consignment = Consignment.new
    self.animals.sort_by {|animal| animal.area}.reverse.each do |animal|

      if consignment.used_boxes.empty?
        first_box = find_box_to_contain(animal.area)
        break self.add_error("no box large enough to contain animal") if first_box.nil?
        add_box_to_consignment(first_box, consignment, animal)
      else
        next_box = nil
        consignment.used_boxes.each do |used_box|

          if used_box.space_available >= animal.area
            next_box = used_box
            break next_box.place_into_box(animal)
          else
            next_box = find_box_to_contain(used_box.space_used + animal.area)            
            if next_box
              transfer_between_boxes(animal, used_box, next_box, consignment)
            end
          end
        end

        if next_box.nil?
          next_box = find_box_to_contain(animal.area)
          break self.add_error("no box large enough to contain animal") if next_box.nil?
          add_box_to_consignment(next_box, consignment, animal)
        end
      end
    end
    consignment
  end

  private

  def add_box_to_consignment(box, consignment, animal)
    box.place_into_box(animal)
    consignment.add_box(box)
  end

  def transfer_between_boxes(animal, current_box, next_box, consignment)
    current_box.contains.map { |animal_in_existing_box| next_box.place_into_box(animal_in_existing_box) }
    next_box.place_into_box(animal)
    consignment.remove_box(current_box)
    next_box
    consignment.add_box(next_box)
  end

  def find_box_to_contain(animal_area)
    selected_box = []
    available_boxes.each { |type, area| selected_box = [type,area] if animal_area <= area }
    Box.new(selected_box[1],selected_box[0]) unless selected_box.empty?
  end

  def available_boxes
    @available_boxes = { 'B1' => 400, 'B2' => 800, 'B3' => 1600 }.sort_by{|k,v| v}.reverse.to_h
  end
end


class Consignment
  attr_accessor :used_boxes

  def initialize
    @used_boxes = []
  end

  def add_box(box)
    used_boxes << box
  end

  def remove_box(box)
    used_boxes.delete(box)
  end
end


class Box
  attr_accessor :area, :type, :contains
  attr_reader :space_available

  def initialize(area, type)
    @area = area
    @type = type
    @contains = []
  end

  def place_into_box(animal)
    contains << animal
  end

  def space_available
    area - space_used
  end

  def space_used
    space_used = 0
    contains.each { |animal| space_used += animal.area }
    space_used
  end
end


class Animal
  attr_accessor :area, :name

  def initialize(area, name)
    @area = area
    @name = name
  end
end