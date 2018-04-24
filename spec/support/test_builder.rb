class TestBuilder < Blocks::Builder
  SOMETHING_ADJACENT = :something_adjacent
  SOMETHING_SURROUNDING = :something_surrounding
  SOMETHING_WRAPPING = :something_wrapping
  SOME_BLOCK = "Some Block Name"

  def initialize(*)
    super
    define SOME_BLOCK do
      SOME_BLOCK
    end
  end

  define_method SOMETHING_ADJACENT do |*args, options|
    content_tag :div, options[:label]
  end

  define_method SOMETHING_SURROUNDING do |*args, options, &content_block|
    content_tag :div, class: options[:label], &content_block
  end

  define_method SOMETHING_WRAPPING do |*args, options, &content_block|
    content_tag :div, class: options["#{options[:wrapper_type]}_label"], &content_block
  end

  def apply_wrappers_to_block(block_name)
    postfix = "-#{block_name}"
    define block_name,
      wrapper: SOMETHING_WRAPPING, wrapper_label: "wrapper#{postfix}",
      wrap_all: SOMETHING_WRAPPING, wrap_all_label: "wrap_all#{postfix}",
      wrap_each: SOMETHING_WRAPPING, wrap_each_label: "wrap_each#{postfix}"
  end

  def apply_hooks_to_block(block_name, around_hooks: true, adjacent_hooks: true)
    postfix = "-#{block_name}"
    if around_hooks
      around block_name, with: SOMETHING_SURROUNDING, label: "around#{postfix}"
      around_all block_name, with: SOMETHING_SURROUNDING, label: "around_all#{postfix}"
      surround block_name, with: SOMETHING_SURROUNDING, label: "surround#{postfix}"
    end

    if adjacent_hooks
      before block_name, with: SOMETHING_ADJACENT, label: "before#{postfix}"
      prepend block_name, with: SOMETHING_ADJACENT, label: "prepend#{postfix}"
      before_all block_name, with: SOMETHING_ADJACENT, label: "before_all#{postfix}"
      after block_name, with: SOMETHING_ADJACENT, label: "after#{postfix}"
      append block_name, with: SOMETHING_ADJACENT, label: "append#{postfix}"
      after_all block_name, with: SOMETHING_ADJACENT, label: "after_all#{postfix}"
    end
  end

  def apply_hooks_and_wrappers_to_block_and_render(block_name, block_to_render: block_name,
                                                               wrappers: true,
                                                               around_hooks: true,
                                                               adjacent_hooks: true,
                                                               content: "BLOCK_CONTENT",
                                                               options: {}, &block)
    apply_hooks_to_block(block_name, around_hooks: around_hooks, adjacent_hooks: adjacent_hooks)
    apply_wrappers_to_block(block_name) if wrappers

    postfix = "-#{block_name}"

    expected_content = [
      ("<div>before_all#{postfix}</div>" if adjacent_hooks),
    	("<div class=\"around_all#{postfix}\">" if around_hooks),
    	("  <div class=\"wrap_all#{postfix}\">" if wrappers),
    ]

    collection = options[:collection]

    if collection
      collection.each_with_index do |item, i|
        item_content = if content.is_a?(Proc)
          content.call(object: item)
        else
          content
        end
        expected_content += [
        	("    <div class=\"wrap_each#{postfix}\">" if wrappers),
        	("      <div class=\"around#{postfix}\">" if around_hooks),
        	("        <div>before#{postfix}</div>" if adjacent_hooks),
        	("        <div class=\"wrapper#{postfix}\">" if wrappers),
        	("          <div class=\"surround#{postfix}\">" if around_hooks),
        	("            <div>prepend#{postfix}</div>" if adjacent_hooks),
        	"            #{item_content}",
        	("            <div>append#{postfix}</div>" if adjacent_hooks),
        	("          </div>" if around_hooks),
        	("        </div>" if wrappers),
        	("        <div>after#{postfix}</div>" if adjacent_hooks),
        	("      </div>" if around_hooks),
        	("    </div>" if wrappers),
        ]
      end
    else
      expected_content += [
      	("    <div class=\"wrap_each#{postfix}\">" if wrappers),
      	("      <div class=\"around#{postfix}\">" if around_hooks),
      	("        <div>before#{postfix}</div>" if adjacent_hooks),
      	("        <div class=\"wrapper#{postfix}\">" if wrappers),
      	("          <div class=\"surround#{postfix}\">" if around_hooks),
      	("            <div>prepend#{postfix}</div>" if adjacent_hooks),
      	"            #{content}",
      	("            <div>append#{postfix}</div>" if adjacent_hooks),
      	("          </div>" if around_hooks),
      	("        </div>" if wrappers),
      	("        <div>after#{postfix}</div>" if adjacent_hooks),
      	("      </div>" if around_hooks),
      	("    </div>" if wrappers),
      ]
    end

    expected_content += [
      ("  </div>" if wrappers),
      ("</div>" if around_hooks),
      ("<div>after_all#{postfix}</div>" if adjacent_hooks)
    ]

    expected_content = sanitize_html(expected_content.compact.join)

    actual_content = sanitize_html(render(block_to_render, options, &block))
    { expected: expected_content, actual: actual_content }
  end
end