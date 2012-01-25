$:.unshift File.dirname($0)
require 'subclu'

EPS = 0.02
MIN_PTS = 2

db = [
		[0.0,0.1,0.2,0.3],
		[0.0,0.1,0.2,0.41],
		[0.0,0.1,0.2,0.42],
		[0.0,0.1,0.2,0.43],
		[0.0,0.1,0.2,0.44],
		[0.5,0.1,0.2,0.45],
		[0.5,0.1,0.2,0.46],
		[0.5,0.1,0.2,0.47],
		[0.5,0.1,0.2,0.48],
		[0.5,0.1,0.2,0.49],
		[0.5,0.1,0.2,0.50],
		[0.5,0.1,0.2,0.51],
		[0.5,0.1,0.2,0.52]
	]


#dbscan runs on all attributes
all_attribute_indices = db[0].index
dbscan = DBscan.new(EuclideanDistance.new(all_attribute_indices))
result = dbscan.run(db, EPS, MIN_PTS)

#test run of subclu, which outputs all possibilities for projected clustering
subclu = SUBCLU.new(JensenShannonDistance)
result = subclu.run(db, EPS, MIN_PTS)

result.each_index do |dim|
	
	puts "DIMENSIONALITY: #{dim+1}"
	
	result[dim].each_pair do |subspace, clusters|
		puts "		#{subspace.inspect}"
		clusters.each do |cluster|
			puts "			#{cluster}"
		end
		puts "\n\n"		
	end
end


