require 'json'

class GithubPullRequest < Rack::App
  def initialize pr_number
    @pr_number = pr_number
  end

  def pt_story_number
    response_body['body'].match(%r{pivotaltracker.com\/story\/show\/(\d+)})[1]
  end

  def title
    response_body['title']
  end

  private

  attr_reader :pr_number

  def response_body
    @response_body ||= JSON.parse(retrieve_details.body)
  end

  def retrieve_details
    query_github_api "repos/#{ENV['GITHUB_REPO']}/pulls/#{pr_number}"
  end

  def query_github_api endpoint
    HTTParty.get(
      github_base_uri + endpoint,
      headers: {
        'Authorization' => "token #{ENV['GITHUB_API_TOKEN']}",
        'User-Agent' => 'flats/release-notifier'
      }
    )
  end

  def github_base_uri
    'https://api.github.com/'
  end
end
