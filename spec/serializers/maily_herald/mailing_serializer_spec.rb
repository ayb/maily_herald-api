require 'rails_helper'

describe MailyHerald::MailingSerializer do

  describe "serializing MailyHerald::Mailing object" do
    let!(:ad_hoc_mailing) { create :ad_hoc_mailing }

    context "setup" do
      it { expect(MailyHerald::Mailing.count).to eq(2) }
    end

    it "should return serialized object" do
      expect(described_class.new(ad_hoc_mailing).as_json).to eq({
        id:         ad_hoc_mailing.id,
        listId:     ad_hoc_mailing.list.id,
        kind:        ad_hoc_mailing.kind,
        conditions: ad_hoc_mailing.conditions,
        from:       ad_hoc_mailing.from,
        mailerName: ad_hoc_mailing.mailer_name,
        name:       ad_hoc_mailing.name,
        state:      ad_hoc_mailing.state,
        subject:    ad_hoc_mailing.subject,
        template:   {
                      html:  ad_hoc_mailing.template_plain,
                      plain: ad_hoc_mailing.template_plain
                    },
        title:      ad_hoc_mailing.title,
        track:      true,
        locked:     false
      })
    end
  end

end
