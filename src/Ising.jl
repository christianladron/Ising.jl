module Ising

export Ensamble, medicionesIndependientes,magnetizaciónensamble,Energíaensamble_Fperiódica, correSweeps

type Ensamble
    configuración::Array{Int}
    H::Float64
    β::Float64
    M::Float64
    δM::Float64
    E::Float64
    δE::Float64
    J::Float64
    function Ensamble(a::Tuple,β::Float64)
	    configuración = rand(-1:2:1,a)
	    new(configuración,0,β,0,0,0,0,1)
    end
end

medicionesIndependientes(a,τ) = a[2*τ:2*τ:(length(a)-mod(length(a),2*τ))]

function eligeEspín(ensamble)
    configuración = ensamble.configuración
    tamaño = size(configuración)
    m = tamaño[1]
    n = tamaño[2]
    ñ = tamaño[3]
    espín = (rand(1:m), rand(1:n), rand(1:ñ))
end

function Erenglónensamble_Flibre(renglón)
    E=0
    l = length(renglón)
    for i in 1:l-1
        E += - renglón[i] * renglón[i+1]
    end
    E
end

function Energíaensamble_Flibre(ensamble)
    configuración = ensamble.configuración
    E = 0
    tamaño = size(configuración)
    m = tamaño[1]
    n = tamaño[2]
    ñ = tamaño[3]
    for i in 1:m, j in 1:n
        E += ensamble.J*Erenglónensamble_Flibre(configuración[i,j,1:end])
    end
    for i in 1:n, j in 1:ñ
        E += ensamble.J*Erenglónensamble_Flibre(configuración[1:end,i,j])
    end
    for i in 1:m, j in 1:ñ
        E += ensamble.J*Erenglónensamble_Flibre(configuración[i,1:end,j])
    end
    E
end

function magnetizaciónensamble(ensamble::Ensamble)
    configuración = ensamble.configuración
    sum(configuración)
end
function magnetizaciónensamble(configuración::Array)
    sum(configuración)
end

function δEnergía(ensamble,espín)
	configuración = ensamble.configuración
	tamaño = size(configuración)
	m = tamaño[1]
	n = tamaño[2]
	ñ = tamaño[3]
	i=espín[1]
	j=espín[2]
	k=espín[3]
	δE = (ensamble.J*configuración[i,j,mod1(k+1,ñ)]+
	ensamble.J*configuración[i,j,mod1(k-1,ñ)]+
	ensamble.J*configuración[i,mod1(j+1,n),k]+
	ensamble.J*configuración[i,mod1(j-1,n),k]+
	ensamble.J*configuración[mod1(i+1,m),j,k]+
	ensamble.J*configuración[mod1(i-1,m),j,k]+
	ensamble.H*ensamble.J/abs(ensamble.J)
	)*2*configuración[i,j,k]
end

function δMagnetización(ensamble,espín)
	configuración = ensamble.configuración
	δM = -2*configuración[espín...]
end

function cambioestado(ensamble,espín)
       ensamble.δE += Ising.δEnergía(ensamble,espín)
       ensamble.δM += -2*ensamble.configuración[espín...]
       end

function paso(ensamble)
	espín = eligeEspín(ensamble)
	δE = δEnergía(ensamble,espín)
	if exp(-ensamble.β*δE)>rand()
		cambioestado(ensamble,espín)
		flipensamble!(ensamble,espín)
	end
end


function sweep(ensamble)
	for j in 1:length(ensamble.configuración)
		paso(ensamble)
	end
end

function correSweeps(ensamble,sweeps)
	Ms = zeros(sweeps)
	Es = zeros(sweeps)
	ensamble.E = Energíaensamble_Fperiódica(ensamble)
	ensamble.M = magnetizaciónensamble(ensamble)
	ensamble.δE = 0
	ensamble.δM = 0
	for i in 1:sweeps
		sweep(ensamble)
		Ms[i] = ensamble.M + ensamble.δM
		Es[i] = ensamble.E + ensamble.δE
	end
	{"M"=>Ms,"E"=>Es}
end


function flipensamble!(ensamble,espín)
    configuración = ensamble.configuración
    configuración[espín...]*= -1
    return espín
end
function Erenglónensamble_Fperiódica(renglón)
    l = length(renglón)
    E = - renglón[1] * renglón[l]
    for i in 1:l-1
        E += - renglón[i] * renglón[i+1]
    end
    E
end


function Energíaensamble_Fperiódica(ensamble::Ensamble)
	configuración=ensamble.configuración
    E = 0
    tamaño = size(configuración)
    m = tamaño[1]
    n = tamaño[2]
    ñ = tamaño[3]
    for i in 1:m, j in 1:n
        E += ensamble.J*Erenglónensamble_Fperiódica(configuración[i,j,1:end])
    end
    for i in 1:n, j in 1:ñ
        E += ensamble.J*Erenglónensamble_Fperiódica(configuración[1:end,i,j])
    end
    for i in 1:m, j in 1:ñ
        E += ensamble.J*Erenglónensamble_Fperiódica(configuración[i,1:end,j])
    end
    E+magnetizaciónensamble(ensamble)*ensamble.H*ensamble.J/abs(ensamble.J)
end


end
