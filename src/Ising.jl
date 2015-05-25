module Ising

export Microestado, medicionesIndependientes,magnetizaciónσ,Energíaσ_Fperiódica, correSweeps

type Microestado
    configuración::Array{Int}
    H::Float64
    β::Float64
    M::Float64
    δM::Float64
    E::Float64
    δE::Float64
    J::Float64
    function Microestado(a::Tuple,β::Float64)
	    configuración = rand(-1:2:1,a)
	    new(configuración,0,β,0,0,0,0,1)
    end
end

medicionesIndependientes(a,τ) = a[2*τ:2*τ:(length(a)-mod(length(a),2*τ))]

function eligeEspín(σ)
    configuración = σ.configuración
    tamaño = size(configuración)
    m = tamaño[1]
    n = tamaño[2]
    ñ = tamaño[3]
    espín = (rand(1:m), rand(1:n), rand(1:ñ))
end

function Erenglónσ_Flibre(renglón)
    E=0
    l = length(renglón)
    for i in 1:l-1
        E += - renglón[i] * renglón[i+1]
    end
    E
end

function Energíaσ_Flibre(σ)
    configuración = σ.configuración
    E = 0
    tamaño = size(configuración)
    m = tamaño[1]
    n = tamaño[2]
    ñ = tamaño[3]
    for i in 1:m, j in 1:n
        E += σ.J*Erenglónσ_Flibre(configuración[i,j,1:end])
    end
    for i in 1:n, j in 1:ñ
        E += σ.J*Erenglónσ_Flibre(configuración[1:end,i,j])
    end
    for i in 1:m, j in 1:ñ
        E += σ.J*Erenglónσ_Flibre(configuración[i,1:end,j])
    end
    E
end

function magnetizaciónσ(σ::Microestado)
    configuración = σ.configuración
    sum(configuración)
end
function magnetizaciónσ(configuración::Array)
    sum(configuración)
end

function δEnergía(σ,espín)
	configuración = σ.configuración
	tamaño = size(configuración)
	m = tamaño[1]
	n = tamaño[2]
	ñ = tamaño[3]
	i=espín[1]
	j=espín[2]
	k=espín[3]
	δE = (σ.J*configuración[i,j,mod1(k+1,ñ)]+
	σ.J*configuración[i,j,mod1(k-1,ñ)]+
	σ.J*configuración[i,mod1(j+1,n),k]+
	σ.J*configuración[i,mod1(j-1,n),k]+
	σ.J*configuración[mod1(i+1,m),j,k]+
	σ.J*configuración[mod1(i-1,m),j,k]+
	σ.H*σ.J/abs(σ.J)
	)*2*configuración[i,j,k]
end

function δMagnetización(σ,espín)
	configuración = σ.configuración
	δM = -2*configuración[espín...]
end

function cambioestado(σ,espín)
       σ.δE += Ising.δEnergía(σ,espín)
       σ.δM += -2*σ.configuración[espín...]
       end

function paso(σ)
	espín = eligeEspín(σ)
	δE = δEnergía(σ,espín)
	if exp(-σ.β*δE)>rand()
		cambioestado(σ,espín)
		flipσ!(σ,espín)
	end
end


function sweep(σ)
	for j in 1:length(σ.configuración)
		paso(σ)
	end
end

function correSweeps(σ,sweeps)
	Ms = zeros(sweeps)
	Es = zeros(sweeps)
	σ.E = Energíaσ_Fperiódica(σ)
	σ.M = magnetizaciónσ(σ)
	σ.δE = 0
	σ.δM = 0
	for i in 1:sweeps
		sweep(σ)
		Ms[i] = σ.M + σ.δM
		Es[i] = σ.E + σ.δE
	end
	{"M"=>Ms,"E"=>Es}
end


function flipσ!(σ,espín)
    configuración = σ.configuración
    configuración[espín...]*= -1
    return espín
end
function Erenglónσ_Fperiódica(renglón)
    l = length(renglón)
    E = - renglón[1] * renglón[l]
    for i in 1:l-1
        E += - renglón[i] * renglón[i+1]
    end
    E
end


function Energíaσ_Fperiódica(σ::Microestado)
	configuración=σ.configuración
    E = 0
    tamaño = size(configuración)
    m = tamaño[1]
    n = tamaño[2]
    ñ = tamaño[3]
    for i in 1:m, j in 1:n
        E += σ.J*Erenglónσ_Fperiódica(configuración[i,j,1:end])
    end
    for i in 1:n, j in 1:ñ
        E += σ.J*Erenglónσ_Fperiódica(configuración[1:end,i,j])
    end
    for i in 1:m, j in 1:ñ
        E += σ.J*Erenglónσ_Fperiódica(configuración[i,1:end,j])
    end
    E+magnetizaciónσ(σ)*σ.H*σ.J/abs(σ.J)
end


end
