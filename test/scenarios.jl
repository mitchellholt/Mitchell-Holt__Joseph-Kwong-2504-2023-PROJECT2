#############################################################################
#############################################################################
#
# This file defines the four scenarios which we test.
#                                                                               
#############################################################################
#############################################################################

"""
Three queues in tandem.
"""
scenario1 = NetworkParameters(  L=3, 
                                alpha_vector = [0.5, 0, 0],
                                mu_vector = ones(3),
                                P = [0 1.0 0;
                                     0 0 1.0;
                                     0 0 0])

"""
Three queues in tandem with option to return back to first queue.
"""
scenario2 = @set scenario1.P  = [0 1.0 0; 
                                 0 0 1.0; 
                                 0.3 0 0] 

"""
A ring of five queues.
"""
scenario3 = NetworkParameters(  L=5, 
                                alpha_vector = ones(5),
                                mu_vector = collect(1:5),
                                P = [0  0.8   0    0   0;
                                     0   0   0.8   0   0;
                                     0   0   0    0.8  0;
                                     0   0   0    0   0.8;
                                     0.8  0   0    0    0])

"""
A large arbitrary network.
"""

Random.seed!(0)
L = 100
P = rand(L,L)
P = P ./ sum(P, dims=2) 
P = P .* (0.2 .+ 0.7rand(L)) 
scenario4 = NetworkParameters(  L=L, 
                                alpha_vector = ones(L),
                                mu_vector = 0.5 .+ rand(L),
                                P = P);
