#!/usr/bin/env ruby

require 'octokit'
require 'json'
require 'yaml'
require 'fileutils'

# 确保 _data 目录存在
FileUtils.mkdir_p('_data')

begin
  # 配置 GitHub API
  # 你需要在环境变量中设置 GITHUB_TOKEN
  client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

  puts "正在获取 peisong-zhang 的仓库..."

  # 获取你的仓库（排除 fork 和私有仓库）
  repos = client.repos('peisong-zhang', sort: 'updated').select do |repo|
    !repo.fork && !repo.private && repo.name != 'peisong-zhang.github.io'
  end

  # 提取仓库名（格式：用户名/仓库名）
  github_repos = repos.first(10).map do |repo|
    "peisong-zhang/#{repo.name}"
  end

  # 保存到 _data/repositories.yml（使用字符串键避免 Ruby Symbol 问题）
  data = {
    'github_users' => ['peisong-zhang'],
    'github_repos' => github_repos,
    'last_updated' => Time.now.strftime('%Y-%m-%d %H:%M:%S')
  }

  File.write('_data/repositories.yml', data.to_yaml)
  puts "✓ 已获取并保存 #{github_repos.length} 个仓库到 _data/repositories.yml"

rescue Octokit::Unauthorized
  puts "❌ GitHub token 无效或已过期"
  exit 1
rescue => e
  puts "❌ 获取仓库失败: #{e.message}"
  exit 1
end
