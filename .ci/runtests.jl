using Pluto, Test

notebookfiles = [
    joinpath((isinteractive() ? pwd() : dirname(@__FILE__)),
             "..", "project$(i)", "project$(i).jl") for i in 1:3
]

@testset for notebookfile in notebookfiles
    @show notebookfile
    session = Pluto.ServerSession()
    notebook = Pluto.SessionActions.open(session, notebookfile; run_async=false);

    println("___ NOTEBOOK LOGS START ___")
    for cell in notebook.cells
        if !isempty(cell.logs)
            println("Logs for cell $(cell.cell_id):")
            for log in cell.logs
                @info "Line $(log["line"])" msg=log["msg"] level=log["level"]
            end
        end
    end
    println("___ NOTEBOOK LOGS END ___")

    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(haskey(ENV, "AA228V_CI_SSH_KEY")))
    @test all(c -> c.errored == false, values(notebook.cells))
    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(pass_small))
    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(pass_medium))
    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(pass_large))
end

