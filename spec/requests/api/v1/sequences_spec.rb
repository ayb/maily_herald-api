require "rails_helper"

describe "Sequences API" do

  describe "GET #show" do
    context "without sequence mailings" do
      let!(:sequence) { create :clean_sequence }

      it { expect(MailyHerald::Sequence.count).to eq(1) }
      it { expect(sequence.mailings.count).to eq(0) }

      context "with incorrect Sequence ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/0" }

        it { expect(response.status).to eq(404) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["error"]).to eq("notFound") }
      end

      context "with correct Sequence ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequence"]).to eq(
              {
                "id"                =>  sequence.id,
                "listId"            =>  sequence.list.id,
                "name"              =>  sequence.name,
                "title"             =>  sequence.title,
                "state"             =>  sequence.state.to_s,
                "startAt"           =>  sequence.start_at.as_json,
                "locked"            =>  false,
                "sequenceMailings"  =>  []
             }
           )
          }
      end
    end

    context "with sequence mailings" do
      let!(:sequence) { create :newsletters }
      let!(:mailing1) { sequence.mailings.where(name: "initial_mail").first }
      let!(:mailing2) { sequence.mailings.where(name: "second_mail").first }
      let!(:mailing3) { sequence.mailings.where(name: "third_mail").first }

      context "setup" do
        it { expect(MailyHerald::Sequence.count).to eq(1) }
        it { expect(MailyHerald::SequenceMailing.count).to eq(3) }
        it { expect(sequence.mailings.count).to eq(3) }
        it { expect(mailing1).not_to be_nil }
        it { expect(mailing2).not_to be_nil }
        it { expect(mailing3).not_to be_nil }
      end

      context "with correct Sequence ID" do
        before { send_request :get, "/maily_herald/api/v1/sequences/#{sequence.id}" }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequence"]).to eq(
              {
                "id"                =>  sequence.id,
                "listId"            =>  sequence.list.id,
                "name"              =>  sequence.name,
                "title"             =>  sequence.title,
                "state"             =>  sequence.state.to_s,
                "startAt"           =>  sequence.start_at.as_json,
                "locked"            =>  false,
                "sequenceMailings"  =>  [
                                          {
                                            "id"                   =>  mailing1.id,
                                            "sequenceId"           =>  sequence.id,
                                            "name"                 =>  mailing1.name,
                                            "title"                =>  mailing1.title,
                                            "subject"              =>  mailing1.subject,
                                            "template"             =>  mailing1.template,
                                            "conditions"           =>  mailing1.conditions,
                                            "from"                 =>  mailing1.from,
                                            "state"                =>  mailing1.state.to_s,
                                            "mailerName"           =>  mailing1.mailer_name.to_s,
                                            "locked"               =>  false,
                                            "absoluteDelayInDays"  =>  mailing1.absolute_delay_in_days
                                          },
                                          {
                                            "id"                   =>  mailing2.id,
                                            "sequenceId"           =>  sequence.id,
                                            "name"                 =>  mailing2.name,
                                            "title"                =>  mailing2.title,
                                            "subject"              =>  mailing2.subject,
                                            "template"             =>  mailing2.template,
                                            "conditions"           =>  mailing2.conditions,
                                            "from"                 =>  mailing2.from,
                                            "state"                =>  mailing2.state.to_s,
                                            "mailerName"           =>  mailing2.mailer_name.to_s,
                                            "locked"               =>  false,
                                            "absoluteDelayInDays"  =>  mailing2.absolute_delay_in_days
                                          },
                                          {
                                            "id"                   =>  mailing3.id,
                                            "sequenceId"           =>  sequence.id,
                                            "name"                 =>  mailing3.name,
                                            "title"                =>  mailing3.title,
                                            "subject"              =>  mailing3.subject,
                                            "template"             =>  mailing3.template,
                                            "conditions"           =>  mailing3.conditions,
                                            "from"                 =>  mailing3.from,
                                            "state"                =>  mailing3.state.to_s,
                                            "mailerName"           =>  mailing3.mailer_name.to_s,
                                            "locked"               =>  false,
                                            "absoluteDelayInDays"  =>  mailing3.absolute_delay_in_days
                                          }
                                        ]
             }
           )
          }
      end
    end
  end

  describe "POST #create" do
    let(:list)     { MailyHerald.list :generic_list }
    let(:start_at) { Time.now + 1.minute }

    it { expect(MailyHerald::Sequence.count).to eq(0) }

    context "with correct params" do
      before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "generic_list", start_at: start_at}}.to_json }

      it { expect(response.status).to eq(200) }
      it { expect(response).to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(MailyHerald::Sequence.count).to eq(1) }
      it { expect(response_json["sequence"]["id"]).to eq(MailyHerald::Sequence.where(name: "new_sequence").first.id) }
      it { expect(response_json["sequence"]["listId"]).to eq(list.id) }
      it { expect(response_json["sequence"]["name"]).to eq("new_sequence") }
      it { expect(response_json["sequence"]["title"]).to eq("New Sequence") }
      it { expect(response_json["sequence"]["state"]).to eq("disabled") }
      it { expect(response_json["sequence"]["startAt"]).to eq(start_at.as_json) }
      it { expect(response_json["sequence"]["locked"]).to be_falsy }
      it { expect(response_json["sequence"]["sequenceMailings"]).to be_kind_of(Array) }
      it { expect(response_json["sequence"]["sequenceMailings"]).to be_empty }
    end

    context "with incorrect params" do
      context "nil title" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {list: "generic_list", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["name"]).to eq("blank") }
        it { expect(response_json["errors"]["title"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "nil list" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "wrong list" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "wrongOne", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["list"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "nil start_at" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "generic_list"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end

      context "wrong start_at" do
        before { send_request :post, "/maily_herald/api/v1/sequences", {sequence: {title: "New Sequence", list: "generic_list", start_at: "{{"}}.to_json }

        it { expect(response.status).to eq(422) }
        it { expect(response).not_to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        it { expect(MailyHerald::Sequence.count).to eq(0) }
      end
    end
  end

  describe "PUT #update" do
    let!(:sequence) { create :clean_sequence }
    let(:start_at)  { "user.created_at + 5.minutes" }

    it { expect(MailyHerald::Sequence.count).to eq(1) }

    context "with incorrect Sequence ID" do
      before { send_request :put, "/maily_herald/api/v1/sequences/0", {sequence: {title: "New Title", state: "enabled", start_at: start_at}}.to_json }

      it { expect(response.status).to eq(404) }
      it { expect(response).not_to be_success }
      it { expect(response_json).not_to be_empty }
      it { expect(response_json["error"]).to eq("notFound") }
    end

    context "with correct Sequence ID" do
      context "with correct params" do
        before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}", {sequence: {title: "New Title", state: "enabled", start_at: start_at}}.to_json }

        it { expect(response.status).to eq(200) }
        it { expect(response).to be_success }
        it { expect(response_json).not_to be_empty }
        it { expect(response_json["sequence"]["title"]).to eq("New Title") }
        it { expect(response_json["sequence"]["state"]).to eq("enabled") }
        it { expect(response_json["sequence"]["startAt"]).to eq(start_at) }
        it { sequence.reload; expect(sequence.title).to eq("New Title") }
      end

      context "with incorrect params" do
        context "blanks" do
          before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}", {sequence: {title: "", list: "", start_at: ""}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["title"]).to eq("blank") }
          it { expect(response_json["errors"]["list"]).to eq("blank") }
          it { expect(response_json["errors"]["startAt"]).to eq("blank") }
        end

        context "wrong start_at" do
          before { send_request :put, "/maily_herald/api/v1/sequences/#{sequence.id}", {sequence: {start_at: "{{"}}.to_json }

          it { expect(response.status).to eq(422) }
          it { expect(response).not_to be_success }
          it { expect(response_json).not_to be_empty }
          it { expect(response_json["errors"]["startAt"]).to eq("notTime") }
        end
      end
    end
  end

end