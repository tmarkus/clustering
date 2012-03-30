require 'measures'

class DBscan
	def initialize(distance_measure)
		@measure = distance_measure
	end

	def neighbors(db, info, p, eps)
		neighborhood = []
		db.each do |p_prime|
			if p != p_prime && @measure.distance(p, p_prime) < eps
				neighborhood.push p_prime
			end
		end	
		
		return neighborhood
	end

	def expand_cluster(db, info, p, cluster, c, eps, min_pts)
		cluster.push p
		if info[p] != :visited 
			info[p] = :visited		
		
			n = neighbors(db, info, p, eps)
			
			if n.size >= min_pts
				n.each do |p_prime|
					if not c.map{|c_prime| c_prime.include? p_prime}.include?(true) #not contained in any cluster?
						expand_cluster(db, info, p_prime, cluster, c, eps, min_pts)
					end
				end
			end		
		end
		return cluster
	end

	def run(db, eps, min_pts)
		c = []
		info = Hash.new
	   
		db.each do |p|
			if info[p] != :visited
				info[p] = :visited
				n = neighbors(db, info, p, eps)

				if n.size < min_pts
					info[p] = :noise
				else
					cluster = [p] #new cluster
					c.push cluster
					n.each do |p_prime|
						if not c.map{|c_prime| c_prime.include? p_prime}.include?(true) #not contained in any cluster?
							expand_cluster(db, info, p_prime, cluster, c, eps, min_pts)
						end
					end
				end
			end
		end      
		return c
	end

end
