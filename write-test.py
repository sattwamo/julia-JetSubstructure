import pyhepmc

allEvent = []

with pyhepmc.open(f"events.hepmc3", "r") as f:
    for i, event in enumerate(f):
        print(i)
        allEvent.append(event)

for i, getEvent in enumerate(allEvent):
    print(f"Event: {i+1}")
    with open(f'./total/{i}.txt', 'w') as fout:
        for j, particle in enumerate(getEvent.particles):
            if particle.status == 1: 
            # Access particle properties such as momentum, energy, etc.
            # print(particle.momentum.px)
                px, py, pz = particle.momentum.px, particle.momentum.py, particle.momentum.pz
                status = particle.status
                energy = particle.momentum.e
                fout.writelines(f"{px}\t{py}\t{pz}\t{energy}\n")
                # print(px,py,pz,energy,status,sep="\t")