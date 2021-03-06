#########################################################################################
# Linear fit with GLM
#########################################################################################
import GLM

function linear_regression_fit_glm(x,y)
    X = hcat(ones(length(x)), x)
    out = GLM.lm(X, y)
    o, s = GLM.coef(out)
    s05, s95 = GLM.confint(out)[2, :]
    return s, s05, s95
end

#########################################################################################
# Linear fit with LsqFit
#########################################################################################
import LsqFit

linearregression(x, p) = @. p[1] + p[2]*x #+ p[3]*log(-x)

function linear_regression_fit_lsqfit(x,y, p0 = [0.0, 0.0])
    linearregression(x, p) = @. p[1] + p[2]*x
    fit = LsqFit.curve_fit(linearregression, x, y, p0)
    s = LsqFit.coef(fit)[2]
    s05, s95 = LsqFit.confidence_interval(fit, 0.05)[2]
    return s, s05, s95
end

#########################################################################################
# Logarithmically corrected fit with LsqFit
#########################################################################################

function logarithmic_corrected_fit_lsqfit(x, y, p0 = [0.0, 0.0, 0.0])
    corrected_fit(x, p) = @. p[1] + p[2]*x + p[3]*log(-x)
    i = findlast(<(0), x)
    if (!isnothing(i) && i < length(x)÷2)
        @info "More than half of the data have log(ε) > 0 for corrected version. Returning standard linear..."
        return linear_regression_fit_glm(x,y)
    elseif !isnothing(i)
        x2 = x[1:i]
        y2 = y[1:i]
    else # last case: all x are negative
        x2 = x
        y2 = y
    end
    if !all(x2 .< 0)
        @info "There still exist positive log(ε) for corrected version. Using standard linear..."
        return linear_regression_fit_glm(x,y)
    end
    try 
        fit = LsqFit.curve_fit(corrected_fit, x2, y2, p0)
        s = LsqFit.coef(fit)[2]
        s05, s95 = LsqFit.confidence_interval(fit, 0.05)[2]
        return s, s05, s95
    catch err
        @info "Corrected version errored with $(err). Using standard linear..."
        return linear_regression_fit_glm(x,y)
    end
end