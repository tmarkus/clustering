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

class JensenShannonDistance < AbstractMeasure
	def distance(p1, p2)
		m = []
		p1.each_index {|i| m[i] = (p1[i]+p2[i]) / 2 }
		return ( 0.5*kl(p1, m) + 0.5*kl(p2, m) )
	end

	def kl(p1, p2)
		sum = 0.0
		p1.each_index do |i|
			if (@attributes.include?(i))
				if (p1[i] > 0)
					sum += p1[i] * Math.log( p1[i] / p2[i] )
				end
			end
		end		
		return sum
	end
end
