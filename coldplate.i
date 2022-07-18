# Fluid properties
mu = 0.001   # Pa*s
rho = 998.2    #kg/m3
cp = 4128      #j/kg-k
k = 0.6     #w/m-k


[Mesh]
  type = FileMesh #Read in mesh from file
  file = liure2.e
[]


[Variables]
   [T_s]
    block = '1 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18'
    initial_condition = 293
  []
  [T1]
    block = '2'
    initial_condition = 293
  []
   [./velocity]
    family = LAGRANGE_VEC
    block='2'
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    block='2'
  [../]
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 1
    z_value = 1e-15
    variable = velocity
  []
[]


[Kernels]
  # Diffusion kernel for each block's variable
  [diff_0]
    type = ADHeatConduction
    variable = T_s
    block ='1 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18'
  []
  [fluid_conduction]
    type = ADHeatConduction
    variable = T1
    block = '2'
    thermal_conductivity = 'k'
  []
  [source]
    type = HeatSource
    variable = T_s
    value = 1e8
    block ='3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18'
  []

 [./mass]
    type = INSADMass
    variable = p
  [../]
  [./mass_pspg]
    type = INSADMassPSPG
    variable = p
  [../]
  [./momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
  [../]
  [./momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  [../]
  [./momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = p
    integrate_p_by_parts = true
  [../]
  [./momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  [../]
 [./temperature_advection]
   type = INSADEnergyAdvection
   variable = T1
 [../]
  [temperature_supg]
    type = INSADEnergySUPG
    variable = T1
    velocity = velocity
  []
[]

[InterfaceKernels]
   [fluid_to_plate_10]
    type = ConjugateHeatTransfer
    variable = T1
    T_fluid = T1
    neighbor_var = 'T_s'
    boundary = '2'
    htc = 5000
  []
[]

[AuxVariables]
  [T]
  []
[]

[AuxKernels]
  [temp_0]
    type = NormalizationAux
    variable = T
    source_variable = T_s
    block = '1 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18'
  []
  [temp_1]
    type = NormalizationAux
    variable = T
    source_variable = T1
    block = '2'
  []
[]

[BCs]
 [./plane_wall]#PCB
  type = ADConvectiveHeatFluxBC
  variable = T_s
  boundary = '1'
  T_infinity = 293
  heat_transfer_coefficient = 7.62
  [../]
  [./vec_inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = '3'
    function_y = 1  #m/s
  [../]
  [./inlet_temp]
    type = DirichletBC
    variable =T1
    boundary = '3'
    value = 293
  [../]
  [./outlet_p]
    type = DirichletBC
    variable = p
    boundary = '4'
    value = 0
  [../]
[]

[Materials]
  [./const_fluid]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu cp k'
    prop_values = '${rho} ${mu}  ${cp}  ${k}'
    block = '2'
  [../]
  [ins_mat]
    type = INSADStabilized3Eqn
    velocity = velocity
    pressure = p
    temperature = T1
    block='2'
  []

  [./plate]
    type = ADHeatConductionMaterial
    thermal_conductivity = 202.4    # W/m k
    specific_heat = 871  # J/kg k
    block = '1'
  [../]

  [./fluid]
    type = ADHeatConductionMaterial
    thermal_conductivity = .6  # W/m k
    specific_heat = 4128    # J/kg K
    block = '2'
  [../]


  [./source]
    type = ADHeatConductionMaterial
    thermal_conductivity = 54    # W/m k
    specific_heat = 330    # J/kg k
    block = '3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18'
  [../]
[]

[Preconditioning]
  [Newton_SMP]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
    solve_type = 'NEWTON'
  []
[]

[Executioner]
  type = Steady
  l_max_its = 5
  nl_max_its = 6000
  nl_rel_tol = 1e-8
  l_tol = 1e-5
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart'
  petsc_options_value = 'lu       superlu_dist                  200'
  automatic_scaling = true
  scheme = bdf2
[]
[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
  file_base = liure_out3
  perf_graph = true
[]
