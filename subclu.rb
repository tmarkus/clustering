$:.unshift File.dirname($0)
require "set"
require "dbscan"

class SUBCLU

	def initialize(measure)
		@measure = measure
	end

	#cluster in the first dimension
	def subclu1(db, eps, min_pts, dimension_blacklist)

		c_and_s = Hash.new
		attributes = []; db.first.each_index {|attribute| attributes.push Set.new([attribute])}

		attributes.each do |attribute|
			if !dimension_blacklist.include?(attribute.to_a.first)
				dbscan = DBscan.new( @measure.new(attribute) )
				c_a = dbscan.run(db, eps, min_pts)

				if  !c_a.empty?
					c_and_s[ attribute ] = c_a
				end
			end		
		end
		return c_and_s
	end

	def generate_candidate_subspaces(c_and_s, dimension_blacklist)

		c_and_s_next = Hash.new

		#create candidate subspaces	
		c_and_s.each_key do |s_1|
			c_and_s.each_key do |s_2|
				if (s_1-s_2).size == 1
					subspace = s_1+s_2				
					if ( (dimension_blacklist - subspace.to_a).eql?(dimension_blacklist) && !filter_subspace?(subspace, c_and_s))
						c_and_s_next[(subspace)] = []  # clusters in higher subspace aren't yet known
					end
				end
			end
		end
		
		return c_and_s_next
	end

	#filter subspaces
	def filter_subspace?(subspace, c_and_s)
		subspace.each do |dim|
			s_k = subspace - [dim]
			if c_and_s[s_k] == nil || c_and_s[s_k].empty?
				return true
			end		
		end
		return false
	end

	#main method
	def run(db, eps, min_pts, max_dimensions = 5, dimension_blacklist = [])
		dimension_blacklist = Set.new(dimension_blacklist)
		
		results = []
	
		#cluster all subspaces in one dimension
		c_and_s = subclu1(db, eps, min_pts, dimension_blacklist)	
		results.push c_and_s
	
		while !c_and_s.empty? && results.size < max_dimensions
			c_and_s_next = generate_candidate_subspaces(c_and_s, dimension_blacklist)
			
			
			to_add_to_c_and_s_next = Hash.new
			to_remove_c_and_s_next = []
			c_and_s_next.each_pair do |subspace, clusters|
				best_subspace = nil
				best_subspace_cluster_count = (2**(0.size * 8 -2) -1) # maximum fixnum value
				subspace.each do |dim|
					s_k = subspace - [dim]
					cluster_count = c_and_s[s_k].map {|cluster| cluster.size}.reduce(:+)
					if (cluster_count < best_subspace_cluster_count)
						best_subspace_cluster_count = cluster_count
						best_subspace = s_k
					end
				end
		
				clusters = []
				c_and_s[best_subspace].each do |cl|
					dbscan = DBscan.new( @measure.new(subspace) )
					clusters += dbscan.run(cl, eps, min_pts)
					
					if not clusters.empty?
						to_add_to_c_and_s_next[subspace] = clusters
					else
						to_remove_c_and_s_next.push(subspace)
					end
				end
			end

			to_add_to_c_and_s_next.each_pair do |subspace, clusters|
				c_and_s_next[subspace] = clusters
			end

			to_remove_c_and_s_next.each do |subspace|
				c_and_s_next.delete(subspace)
			end


			results.push c_and_s_next if not c_and_s_next.empty?
			c_and_s = c_and_s_next
		end		
		return results
	end

end

