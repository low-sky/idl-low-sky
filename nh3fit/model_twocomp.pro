function model_twocomp,xin, p 

  p1 = p[0:5]
  p2 = p[6:*]

  model1 = modelspec(xin,p1)
  model2 = modelspec(xin,p2)
  model = model1+model2

  return,model1+model2
end
