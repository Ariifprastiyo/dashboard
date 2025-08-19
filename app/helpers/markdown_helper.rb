# frozen_string_literal: true

module MarkdownHelper
  def markdown(text)
    return '' if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      filter_html: true,
      link_attributes: { rel: 'nofollow', target: "_blank" }
    )
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true,
      tables: true
    )

    sanitize(markdown.render(text))
  end
end
