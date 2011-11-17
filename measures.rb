class AbstractMeasure
	def initialize(attributes)
		@attributes = attributes
	end
	
	def distance(point1, point2)
		raise "You should probably override this method!"
	end
end


class EuclideanDistance < AbstractMeasure
	def distance(p1,p2)
	  sum_of_squares = 0
	  p1.each_with_index do |p1_coord,index|
		if (@attributes.include?(index))
			sum_of_squares += (p1_coord - p2[index]) ** 2
		end
	  end
	  Math.sqrt( sum_of_squares )
	end
end
