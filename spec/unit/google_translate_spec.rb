require 'spec_helper'

RSpec.describe RailsI18nManager::GoogleTranslate, type: :model do

  before do
    allow(Rails.env).to receive(:test?).and_return(false)
    allow(RailsI18nManager.config).to receive(:google_translate_api_key).and_return("some-api-key")
    allow(RailsI18nManager.config).to receive(:translate_manager).and_return(manager)
  end

  context "translate" do
    let(:manager) { double("manager", translate: "") }

    it "returns false for unsupported locales" do
      expect(RailsI18nManager::GoogleTranslate.translate("foo", from: "bar", to: "baz")).to eq(false)
    end

    context "with valid locates" do
      let(:manager) { double("manager", translate: "foo") }

      it "returns false in test environment" do
        allow(Rails.env).to receive(:test?).and_return(true)
        expect(RailsI18nManager::GoogleTranslate.translate("foo", from: "en", to: "es")).to eq(false)
      end

      context "with missing api key and manager returned false" do
        let(:manager) { double("manager", translate: false) }

        before do
          allow(RailsI18nManager.config).to receive(:google_translate_api_key).and_return(nil)
          allow(Rails.env).to receive(:development?).and_return(true)
        end

        it "returns false in development environment if api key is missing" do
          expect(RailsI18nManager::GoogleTranslate.translate("foo", from: "en", to: "es")).to eq(false)
        end
      end

      context "with html" do
        let(:manager) { double("manager", translate: "foo") }

        it "returns false if HTML string provided" do
          expect(RailsI18nManager::GoogleTranslate.translate("<foo>", from: "en", to: "es")).to eq(false)
        end
      end

      it "returns translated if < or > string provided" do
        expect(RailsI18nManager::GoogleTranslate.translate("<foo", from: "en", to: "es")).to eq("foo")
        expect(RailsI18nManager::GoogleTranslate.translate("foo>", from: "en", to: "es")).to eq("foo")
      end

      context "with single quote HTML entities" do
        let(:manager) { double("manager", translate: "&#39;foo&#39;") }

        it "replaces single quote HTML entities with actual single quotes" do
          expect(RailsI18nManager::GoogleTranslate.translate("unrelated", from: "en", to: "es")).to eq("'foo'")
        end
      end

      context "with '% {' with ' %{' for es locale" do
        let(:manager) { double("manager", translate: "% {foo") }

        it "replaces '% {' with ' %{' for es locale" do
          expect(RailsI18nManager::GoogleTranslate.translate("unrelated", from: "en", to: "es")).to eq("%{foo")
        end
      end

      context "with nil" do
        let(:manager) { double("manager", translate: nil) }

        it "returns nil if text was not able to be translated" do
          expect(RailsI18nManager::GoogleTranslate.translate("unrelated", from: "en", to: "es")).to eq(nil)
        end
      end

      context "with bonjour" do
        let(:manager) { double("manager", translate: "bonjour") }

        it "returns translated text" do
          expect(RailsI18nManager::GoogleTranslate.translate("hello", from: "en", to: "fr")).to eq("bonjour")
        end
      end
    end
  end
end
