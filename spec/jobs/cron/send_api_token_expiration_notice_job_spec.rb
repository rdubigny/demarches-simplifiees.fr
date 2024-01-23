RSpec.describe Cron::SendAPITokenExpirationNoticeJob, type: :job do
  describe 'perform' do
    let(:administrateur) { create(:administrateur) }
    let!(:token) { APIToken.generate(administrateur).first }
    let(:mailer_double) { double('mailer', deliver_later: true) }
    let(:today) { Time.zone.local(2018, 01, 01).to_date }

    def perform_now
      Cron::SendAPITokenExpirationNoticeJob.perform_now
    end

    before do
      Timecop.freeze(today)
      allow(APITokenMailer).to receive(:expiration).and_return(mailer_double)
    end

    after { Timecop.return }

    context 'when the token does not expire' do
      before { perform_now }

      it { expect(mailer_double).not_to have_received(:deliver_later) }
    end

    context 'when the token expires in 6 months' do
      before do
        token.update(expires_at: today + 6.months)
        perform_now
      end

      it { expect(mailer_double).not_to have_received(:deliver_later) }
    end

    context 'when the token expires less than a month' do
      before do
        token.update(expires_at: today + 1.month - 2.days)
        2.times.each { perform_now }
      end

      it { expect(mailer_double).to have_received(:deliver_later).once }
    end

    context 'when the token expires less than a week' do
      before do
        token.update(expires_at: today + 1.week - 2.days)
        2.times.each { perform_now }
      end

      it { expect(mailer_double).to have_received(:deliver_later).once }
    end

    context 'when we simulate the whole sequence' do
      before do
        token.update(expires_at: today + 1.month - 2.days)
        2.times.each { perform_now }
        token.update(expires_at: today + 1.week - 2.days)
        2.times.each { perform_now }
        token.update(expires_at: today + 2.hours)
        2.times.each { perform_now }
      end

      it do
        expect(mailer_double).to have_received(:deliver_later).exactly(3).times
        expect(token.reload.expiration_notices_sent).to match_array(["0 days..1 day", "1 day..1 week", "1 week..1 month"])
      end
    end
  end
end
