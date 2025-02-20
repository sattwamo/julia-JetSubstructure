using ArgParse
using JetReconstruction
using CSV
using DataFrames

function makeJets(data::Vector{PseudoJet})
    finaljets = jet_reconstruct(data; p = -1, R = 0.4, recombine = +, strategy = RecoStrategy.N2Plain)

    finaljets
end

function parse_command_line(args)
    s = ArgParseSettings(autofix_names = true)
    @add_arg_table! s begin
        "--filter"
        help = "Set filtering parameters"
        arg_type = JetFilter
        default = JetFilter(0.3, 3)

        "--trim"
        help = "Set trimming parameters"
        arg_type = JetTrim
        default = JetTrim(0.3, 0.3, JetAlgorithm.CA)

        "--massdrop"
        help = "Set mass drop parameters"
        arg_type = MassDropTagger
        default = MassDropTagger(0.67, 0.09)

        "--softdrop"
        help = "Set soft drop parameters"
        arg_type = SoftDropTagger
        default = SoftDropTagger(0.1, 2.0)

        "--nsamples", "-n"
        help = "Number of measurement points to acquire"
        arg_type = Int
        default = 16

        "--results"
        help = "Write results in CSV format to this file"

        "files"
        help = "Event files to process"
        required = true
        nargs = '+'

    end
    return parse_args(args, s; as_symbols = true)
end

function main()
    args = parse_command_line(ARGS)

    if endswith(args[:files][1], ".csv")
		if length(args[:files]) > 1
			println("When CSV input is given, only one file can be used")
			exit(1)
		end
		hepmc3_files_df = CSV.read(args[:files][1], DataFrame)
		input_file_path = dirname(args[:files][1])
		input_files = hepmc3_files_df[:, :File]
		input_files_full = map(fname -> joinpath(input_file_path, fname), input_files)
		hepmc3_files_df[:, :File_path] = input_files_full
	else
		input_files_full = args[:files]
		hepmc3_files_df = DataFrame("File_path" => input_files_full)
		hepmc3_files_df[:, :File] = map(basename, hepmc3_files_df[:, :File_path])
	end

    filter_timing = Float64[]
    trimming_timing = Float64[]
    massdrop_timing = Float64[]
    softdrop_timing = Float64[]

	n_samples = Int[]

    for event_file in hepmc3_files_df[:, :File_path]
        allEvents = read_final_state_particles(event_file)
        event_num = length(allEvents)
        avg_filter_time = 0.0
        avg_trimming_time = 0.0
        avg_massdrop_time = 0.0
        avg_softdrop_time = 0.0
        
        push!(n_samples, args[:nsamples])

        if args[:nsamples] > 1
            # @info "Doing initial warm-up run"
            for event in allEvents
                cluster = makeJets(event)
                allJets = inclusive_jets(cluster; ptmin = 2.0, T = PseudoJet)

                [jet_filtering(jet, cluster, args[:filter]) for jet in allJets]
                [jet_trimming(jet, cluster, args[:trim]) for jet in allJets]
                [mass_drop(jet, cluster, args[:massdrop]) for jet in allJets]
                [soft_drop(jet, cluster, args[:softdrop]) for jet in allJets]
            end
        end

        for j in 1:args[:nsamples]
            global counts = 0
            for event in allEvents
                counts += length(event)
                cluster = makeJets(event)
                allJets = inclusive_jets(cluster; ptmin = 2.0, T = PseudoJet)

                avg_filter_time += @elapsed [jet_filtering(jet, cluster, args[:filter]) for jet in allJets]
                avg_trimming_time += @elapsed [jet_trimming(jet, cluster, args[:trim]) for jet in allJets]
                avg_massdrop_time += @elapsed [mass_drop(jet, cluster, args[:massdrop]) for jet in allJets]
                avg_softdrop_time += @elapsed [soft_drop(jet, cluster, args[:softdrop]) for jet in allJets]
            end

            counts /= event_num 
        end

        avg_filter_time /= args[:nsamples] * 10 ^ -4 
        avg_trimming_time /= args[:nsamples] * 10 ^ -4
        avg_massdrop_time /= args[:nsamples] * 10 ^ -4
        avg_softdrop_time /= args[:nsamples] * 10 ^ -4

        push!(filter_timing, avg_filter_time)
        push!(trimming_timing, avg_trimming_time)
        push!(massdrop_timing, avg_massdrop_time)
        push!(softdrop_timing, avg_softdrop_time)

    end

    hepmc3_files_df[:, :n_samples] = n_samples
    hepmc3_files_df[:, :filter_time] = filter_timing
    hepmc3_files_df[:, :trimming_time] = trimming_timing
    hepmc3_files_df[:, :massdrop_time] = massdrop_timing
    hepmc3_files_df[:, :softdrop_time] = softdrop_timing

    println(hepmc3_files_df)
    
    if !isnothing(args[:results])
		CSV.write(args[:results], hepmc3_files_df)
	end
end

main()