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
    for (cell_id, cell) in notebook.cells
        if !isempty(cell.logs)
            println("Logs for cell $(cell_id):")
            for log in cell.logs
                # Pluto logs are dict-like. "msg" is the main text.
                # Depending on Pluto version, it might be a Dict or a Struct.
                msg = get(log, "msg", log) 
                println("  [$(get(log, "level", "INFO"))] $msg")
            end
        end
    end
    println("___ NOTEBOOK LOGS END ___")

    @test all(c -> c.errored == false, values(notebook.cells))
    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(pass_small))
    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(pass_medium))
    @test Pluto.WorkspaceManager.eval_fetch_in_workspace((session, notebook), :(pass_large))
end

