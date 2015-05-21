module StatisticsCalculations
  def get_latest_updated(limit = 10, timelimit = Time.at(0), prj_filter = nil, pkg_filter = nil)
    packages = Package.includes(:project).where(updated_at: timelimit..Time.now).order("updated_at DESC").limit(limit).pluck(:name, "projects.name as project", :updated_at).map { |name, project, at| [at, :package, name, project] }
    projects = Project.where(updated_at: timelimit..Time.now).order("updated_at DESC").limit(limit).pluck(:name, :updated_at).map { |name, at| [at, name, :project] }

    # TODO: Optimization? It would be nice to keep the regex though.                                                                                                                                                                               
    unless pkg_filter.nil?
      packages.select! { |p| p[2] =~ /#{pkg_filter}/ }
    end
    unless prj_filter.nil?
      projects.select! { |p| p[1] =~ /#{prj_filter}/ }
      packages.select! { |p| p[3] =~ /#{prj_filter}/ }
    end

    list = packages + projects
    list.sort! { |a, b| b[0] <=> a[0] }
    return list if limit.nil?
    list.first(limit)
  end
end

