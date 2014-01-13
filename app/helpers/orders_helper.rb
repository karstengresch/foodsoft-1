# encoding: utf-8
module OrdersHelper

  def update_articles_link(order, text, view)
    link_to text, order_path(order, view: view), remote: true
  end

  def order_pdf(order, document, text)
    link_to text, order_path(order, document: document, format: :pdf), title: I18n.t('helpers.orders.order_pdf')
  end

  def options_for_suppliers_to_select
    options = [[I18n.t('helpers.orders.option_choose')]]
    options += Supplier.all.map {|s| [ s.name, url_for(action: "new", supplier_id: s)] }
    options += [[I18n.t('helpers.orders.option_stock'), url_for(action: 'new', supplier_id: 0)]]
    options_for_select(options)
  end

  def units_history_line(order_article)
    if order_article.order.open?
      nil
    else
      units_info = "#{order_article.units_to_order} #{OrderArticle.human_attribute_name :units_to_order, count: order_article.units_to_order}"
      units_info += ", #{order_article.units_billed} #{OrderArticle.human_attribute_name :units_billed_short, count: order_article.units_billed}" unless order_article.units_billed.nil?
      units_info += ", #{order_article.units_received} #{OrderArticle.human_attribute_name :units_received_short, count: order_article.units_received}" unless order_article.units_received.nil?
    end
  end

  # can be article or article_price
  #   icon: `false` to not show the icon
  #   soft_uq: `true` to hide unit quantity specifier on small screens
  #            sensible in tables with multiple columns calling `pkg_helper`
  def pkg_helper(article, options={})
    return nil if article.unit_quantity == 1
    uq_text = "&times; #{article.unit_quantity}".html_safe
    uq_text = content_tag(:span, uq_text, class: 'hidden-phone') if options[:soft_uq]
    if options[:icon].nil? or options[:icon]
      pkg_helper_icon(uq_text)
    else
      pkg_helper_icon(uq_text, tag: :span)
    end
  end
  def pkg_helper_icon(c=nil, options={})
    options = {tag: 'i', class: ''}.merge(options)
    if c.nil?
      c = "&nbsp;".html_safe
      options[:class] += " icon-only"
    end
    content_tag(options[:tag], c, class: "package #{options[:class]}").html_safe
  end
  
  def article_price_change_hint(order_article, gross=false)
    return nil if order_article.article.price == order_article.price.price
    title = "#{t('helpers.orders.old_price')}: #{number_to_currency order_article.article.price}"
    title += " / #{number_to_currency order_article.article.gross_price}" if gross
    content_tag(:i, nil, class: 'icon-asterisk', title: j(title)).html_safe
  end
  
  def receive_input_field(form)
    order_article = form.object
    units_expected = (order_article.units_billed or order_article.units_to_order) *
      1.0 * order_article.article.unit_quantity / order_article.article_price.unit_quantity
    
    input_classes = 'input input-nano units_received'
    input_classes += ' package' unless order_article.article_price.unit_quantity == 1
    input_html = form.text_field :units_received, class: input_classes,
      data: {'units-expected' => units_expected},
      disabled: order_article.result_manually_changed?,
      autocomplete: 'off'
    
    if order_article.result_manually_changed?
      input_html = content_tag(:span, class: 'input-prepend intable', title: t('.field_locked_title', default: '')) {
        button_tag(nil, type: :button, class: 'btn unlocker') {
          content_tag(:i, nil, class: 'icon icon-unlock')
        } + input_html
      }
    end

    input_html.html_safe
  end
end
