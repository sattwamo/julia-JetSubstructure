import fastjet as fj
import time
import matplotlib.pyplot as plt
import numpy as np

def readFile(number):
    # datafile = open(f"data.dat","r")
    datafile = open(f"./allData/{number}.txt","r")
    lines = datafile.readlines()
    datafile.close()

    return lines

def loadParticles(lines):
    event = []

    for line in lines:
        arr = line.split("\t")
        particle = fj.PseudoJet(float(arr[0]), float(arr[1]), float(arr[2]), float(arr[3]))

        event.append(particle)
    
    return event

def makeJets(data):
    jet_def = fj.JetDefinition(fj.cambridge_algorithm, 1.0)
    jet_cluster = fj.ClusterSequence(data, jet_def)
    # jets = jet_cluster.inclusive_jets()

    # return jets
    return jet_cluster

def totalJets(jets):
    count = 0

    for jet in jets:
        if jet.pt() > 0:
            
            count += 1

    return count
    
def jetData(jets):
    count = 0

    for jet in jets:
        if jet.pt() > 0:
            count += 1
            print(f"Jet {count} -> Rapidity: {jet.rap()}, Phi: {jet.phi()}, pT: {jet.pt()}")

def plotPT(jets):    
    pt = []

    for jet in jets:
        if 0 < jet.pt():
            pt.append(jet.pt())

    MAX = max(pt)
    MIN = min(pt)

    xrange = np.linspace(MIN, MAX+1, 51)
    # print(xrange)

    print(np.mean(pt))
    print(np.std(pt))

    plt.hist(pt, bins=xrange)
    plt.yscale("log")
    plt.savefig("pt-python.png")

def plotRAP(jets):    
    rap = []

    for jet in jets:
        if 0 < jet.pt():
            rap.append(jet.rap())

    MAX = max(rap)
    MIN = min(rap)

    xrange = np.linspace(MIN, MAX+1, 51)
    # print(xrange)

    plt.hist(rap, bins=xrange)
    plt.show()

def plotPHI(jets):    
    phi = []

    for jet in jets:
        if 0 < jet.pt():
            phi.append(jet.phi())

    MAX = max(phi)
    MIN = min(phi)

    xrange = np.linspace(MIN, MAX+1, 51)
    # print(xrange)

    plt.hist(phi, bins=xrange)
    plt.show()

file = readFile(0)
particle_data = loadParticles(file)
start = time.time()
cluster = makeJets(particle_data)
event = cluster.inclusive_jets()
end = time.time() - start
# print(totalJets(event))
jetData(event)
# print(end)


# print(result)
# plotRAP(event)
# plotPHI(event)
# plotPT(event)