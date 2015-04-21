class ScholarsphereAuditService < Sufia::GenericFileAuditService

  def audit_stat
    audit_results = ChecksumAuditLog.logs_for(generic_file.id, "content").collect { |result| result["pass"] }

    # check how many non runs we had
    non_runs = audit_results.reduce(0) { |sum, value| value == NO_RUNS ? sum += 1 : sum }
    if non_runs == 0
      audit_results.reduce(true) { |sum, value| sum && value }
    elsif non_runs < audit_results.length
      result = audit_results.reduce(true) { |sum, value| value == NO_RUNS ? sum : sum && value }
      "Some audits have not been run, but the ones run were #{result ? 'passing' : 'failing'}."
    else
      'Audits have not yet been run on this file.'
    end
  end

end
