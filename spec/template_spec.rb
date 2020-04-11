require 'spec_helper'

module MFT

  describe 'Template Tests' do
    context 'with a rating in the context' do
      it 'renders a bar of stars' do
        template = <<~EOTEMPLATE
          {%- capture left -%}{{ rating }}{%- endcapture -%}
          {%- capture right -%}{{ 5 | minus: left }}{%- endcapture -%}
          {{"★★★★★" | truncate: left, ""}}{{"☆☆☆☆☆" | truncate: right, "" }} ({{rating}})
        EOTEMPLATE
        output = Liquid::Template.parse(template).render({'rating' => 3})
        puts output
        expect(output.strip).to eq('★★★☆☆ (3)')
      end
    end
  end

end

