class ScholarsphereBatchUpdateJob < BatchUpdateJob
  def queue_additional_jobs(gf)
    super
    Sufia.queue.push(ShareNotifyJob.new(gf.id))
  end
end
