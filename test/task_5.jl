#############################################################################
#############################################################################
#
# This file implements the testing for task 5.
#                                                                               
#############################################################################
#############################################################################

"""
Returns the first quantile, the median and the third quantile for the sojourn 
time of a customer in the netowrk.
"""
function estimate_q1_median_q3_customer_time(
        parameters :: NetworkParameters, c_s :: Float64) :: Vector{Float64}

    rho_star = 0.8

    customers = sim_net_customers(
        set_scenario(parameters, rho_star = rho_star, c_s = c_s)).customers
    data = [c.departure_time - c.arrival_time for c in customers if c.departure_time > 0]

    return nquantile(data, 4)[2:4]
end



