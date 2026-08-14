function current_gitlab_project()
  local remote = vim.fn.systemlist(
    "git config --get remote.origin.url"
  )[1]

  if vim.v.shell_error ~= 0 or not remote then
    return nil
  end

  -- git@gitlab.com:group/project.git
  if remote then
    return remote:gsub("%.git$", ""):gsub(".*:", "")
  end

  return nil
end



vim.pack.add {
  {
    src = 'https://github.com/emrearmagan/atlas.nvim',
  },
}

local project = current_gitlab_project()

require('atlas').setup {
  -- Too lazy to manage a statusline per split? Same. Make it global.
  global_statusline = true,

  pulls = {
    -- See Pulls Configuration below.
    providers = {
      ---@type AtlasGitLabPullsConfig
      gitlab = {
        base_url = 'https://git.result.si',
        token = vim.env.GITLAB_TOKEN,
        cache_ttl = 300,

        ---@type AtlasGitLabPullsViewConfig[]
        views = {
          {
            name = 'Assigned',
            key = '1',
            scope = 'assigned_to_me',
          },
          {
            name = 'Reviewing',
            key = '3',
            scope = 'all',
            extra_params = { reviewer_id = 'any' },
          },
          -- Single project
          {
            name = 'Current project',
            key = 'C',
            project = project,
          },
          -- Whole group, all projects under it
          -- {
          --   name = 'GitLab Org',
          --   key = 'O',
          --   group = 'gitlab-org',
          -- },
        },

        bookmarks = {
          key = 'S', -- default
          label = 'Search', -- default
          project = project,
          items = {
            ['Reviewing'] = { scope = 'all', extra_params = { reviewer_id = '37' } },
            ['Merged by me'] = { scope = 'all', state = 'merged', author_username = 'skofm' },
          },
        },
      },
    },
  },
  issues = {
    -- See Issue Configuration below.
    providers = {
      ---@type AtlasJiraIssuesConfig
      jira = {
        base_url = 'https://result-doo.atlassian.net',
        email = 'mark.skof@result.si',
        --- See: https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/
        token = vim.env.JIRA_TOKEN,
        auth_method = 'basic', -- "basic" or "bearer", defaults to "basic". If using bearer, set `token` to your API token.
        api_type = 'cloud', -- either "cloud" or "server", defaults to "cloud". Cloud API is v3, server API is v2
        cache_ttl = 300,

        project_config = {
          -- The Jira custom field ID used for story points. Defaults to "customfield_10016".
          story_points_field = 'customfield_10016',
          issue_types = {
            ['Maintenance'] = { icon = '', hl_group = 'AtlasTextWarning' },
            ['Infrastructure'] = { icon = '󰒋', hl_group = 'AtlasLogInfo' },
          },

          KAN = {
            customfield_10003 = {
              name = 'Approvers',
              format = function(value)
                if type(value) ~= 'table' or #value == 0 then
                  return nil -- nil hides the field
                end
                return table.concat(value, ', ')
              end,
              hl_group = 'AtlasChipActive',
              display = 'chip', -- "chip" or "table"
            },
          },
        },

        ---@type AtlasJiraViewConfig[]
        views = {
          {
            name = 'My Board',
            key = 'M',
            layout = 'plain',
            jql = 'project = KAN AND assignee = currentUser() ORDER BY updated DESC',
          },
          {
            name = 'Team Board',
            key = 'T',
            layout = 'compact',
            jql = 'project = KAN ORDER BY updated DESC',
          },
        },

        bookmarks = {
          key = 'J', -- default
          label = 'JQL', -- default
          items = {
            ['Backlog'] = 'project = KAN AND statusCategory != Done AND (sprint IS EMPTY OR sprint NOT IN openSprints()) ORDER BY Rank ASC',
            ['Next sprint'] = 'project = KAN AND sprint in futureSprints() ORDER BY Rank ASC',
            ['My open'] = 'assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC',
          },
        },
      },
    },
  },
}
