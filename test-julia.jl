using LorentzVectorHEP
# using Plots
using JetReconstruction
# using Base.Threads
# using StatsBase 



function readFile(file::Int64)
    # datafile = open("data.dat","r")
    datafile = open("./allData/$(file).txt","r")
    lines = readlines(datafile)
    close(datafile)

    lines
end

function loadParticles(lines::Array{String})
    jetData = Vector{PseudoJet}(undef, length(lines))

    i = 1
    for line in lines
        
        arr = split(line, "\t")           
        px = parse(Float64, arr[1])
        py = parse(Float64, arr[2])
        pz = parse(Float64, arr[3])
        E = parse(Float64, arr[4])
        
        jetData[i] = PseudoJet(px, py, pz, E)
        i += 1
    end

    jetData
end

function makeJets(data::Vector{PseudoJet})
    finaljets = @fastmath plain_jet_reconstruct(data; p = 0, R = 1.0)
    finaljets
end

function totalJets(jets)

    NUM = length(jets)
    count = 0
    
    for j in 1:NUM
        count += 1
    end

    count
end
    
function displayJetData(jets)

    NUM = length(jets)
    count = 0
    
    for j in 1:NUM
        if 0 < jets[j].pt 
            count += 1
            println("$(count) -> Rapidity: $(jets[j].eta), Phi: $(jets[j].phi), pT: $(jets[j].pt)")
        end
    end

end

function plotPT(jets)
    NUM = length(jets)
    pt = []
    
    for j in 1:NUM
        if 0 < jets[j].pt 
            push!(pt, jets[j].pt)
        end
    end

    MIN = minimum(pt)
    MAX = maximum(pt)

    x = LinRange(MIN, MAX+1, 51)

    println(mean(pt))
    println(std(pt))
    display(histogram(pt, bins=x, yaxis=(:log10)))
    # savefig(histogram(pt, bins=x, yaxis=(:log10)), "pt-julia.png")
    # sleep(10)
end

function plotRAP(jets)
    NUM = length(jets)
    rap = []
    
    for j in 1:NUM
        if 0 < jets[j].pt # < 20   
            push!(rap, jets[j].rap)
        end
    end

    MIN = minimum(rap)
    MAX = maximum(rap)

    x = LinRange(MIN, MAX+1, 51)

    display(histogram(rap, bins=x))
    sleep(15)
end

function plotPHI(jets)
    NUM = length(jets)
    phi = []
    
    for j in 1:NUM
        if 0 < jets[j].pt   
            push!(phi, jets[j].phi)
        end
    end

    MIN = minimum(phi)
    MAX = maximum(phi)

    x = LinRange(MIN, MAX+1, 51)

    display(histogram(phi, bins=x))
    sleep(10)
end

function main()
    @time fullData = readFile(0)
    @time particles = loadParticles(fullData)
    
    
    data = makeJets(particles)
    hist = data.history
    jets = data.jets

    # println(hist)
    # println(data.Qtot)
    data = inclusive_jets(data)
    # println(data[1])
    displayJetData(data)
    
    # plotRAP(data)
    # plotPHI(data)
    # plotPT(data)
end


# main()