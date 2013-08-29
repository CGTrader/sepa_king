# encoding: utf-8
require 'spec_helper'

describe SEPA::DirectDebit do
  let(:direct_debit) {
    SEPA::DirectDebit.new name:                'Gläubiger GmbH',
                          bic:                 'BANKDEFFXXX',
                          iban:                'DE87200500001234567890',
                          creditor_identifier: 'DE98ZZZ09999999999'
  }

  describe :new do
    it 'should accept missing options' do
      expect {
        SEPA::DirectDebit.new
      }.to_not raise_error
    end
  end

  describe :add_transaction do
    it 'should add valid transactions' do
      3.times do
        direct_debit.add_transaction(direct_debt_transaction)
      end

      expect(direct_debit).to have(3).transactions
    end

    it 'should fail for invalid transaction' do
      expect {
        direct_debit.add_transaction name: ''
      }.to raise_error(ArgumentError)
    end
  end

  describe :to_xml do
    context 'for invalid creditor' do
      it 'should fail' do
        expect {
          SEPA::DirectDebit.new.to_xml
        }.to raise_error(RuntimeError)
      end
    end

    context 'for valid creditor' do
      context 'without requested_date given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction name:                      'Zahlemann & Söhne GbR',
                              bic:                       'SPUEDE2UXXX',
                              iban:                      'DE21500500009876543210',
                              amount:                    39.99,
                              reference:                 'XYZ/2013-08-ABO/12345',
                              remittance_information:    'Unsere Rechnung vom 10.08.2013',
                              mandate_id:                'K-02-2011-12345',
                              mandate_date_of_signature: Date.new(2011,1,25)

          sdd.add_transaction name:                      'Meier & Schulze oHG',
                              bic:                       'GENODEF1JEV',
                              iban:                      'DE68210501700012345678',
                              amount:                    750.00,
                              reference:                 'XYZ/2013-08-ABO/6789',
                              remittance_information:    'Vielen Dank für Ihren Einkauf!',
                              mandate_id:                'K-08-2010-42123',
                              mandate_date_of_signature: Date.new(2010,7,25)

          sdd.to_xml
        end

        it 'should create valid XML file' do
          expect(subject).to validate_against('pain.008.002.02.xsd')
        end

        it 'should contain <ReqdColltnDt>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/ReqdColltnDt', Date.today.next.iso8601)
        end

        it 'should contain <PmtMtd>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/PmtMtd', 'DD')
        end

        it 'should contain <BtchBookg>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/BtchBookg', 'true')
        end

        it 'should contain <NbOfTxs>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/NbOfTxs', '2')
        end

        it 'should contain <CtrlSum>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CtrlSum', '789.99')
        end

        it 'should contain <Cdtr>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/Cdtr/Nm', 'Glaeubiger GmbH')
        end

        it 'should contain <CdtrAcct>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CdtrAcct/Id/IBAN', 'DE87200500001234567890')
        end

        it 'should contain <CdtrAgt>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CdtrAgt/FinInstnId/BIC', 'BANKDEFFXXX')
        end

        it 'should contain <CdtrAgt>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/CdtrSchmeId/Id/PrvtId/Othr/Id', 'DE98ZZZ09999999999')
        end

        it 'should contain <EndToEndId>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/PmtId/EndToEndId', 'XYZ/2013-08-ABO/12345')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/PmtId/EndToEndId', 'XYZ/2013-08-ABO/6789')
        end

        it 'should contain <InstdAmt>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/InstdAmt', '39.99')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/InstdAmt', '750.00')
        end

        it 'should contain <MndtId>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DrctDbtTx/MndtRltdInf/MndtId', 'K-02-2011-12345')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DrctDbtTx/MndtRltdInf/MndtId', 'K-08-2010-42123')
        end

        it 'should contain <DtOfSgntr>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DrctDbtTx/MndtRltdInf/DtOfSgntr', '2011-01-25')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DrctDbtTx/MndtRltdInf/DtOfSgntr', '2010-07-25')
        end

        it 'should contain <DbtrAgt>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DbtrAgt/FinInstnId/BIC', 'SPUEDE2UXXX')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DbtrAgt/FinInstnId/BIC', 'GENODEF1JEV')
        end

        it 'should contain <Dbtr>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/Dbtr/Nm', 'Zahlemann  Soehne GbR')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/Dbtr/Nm', 'Meier  Schulze oHG')
        end

        it 'should contain <DbtrAcct>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/DbtrAcct/Id/IBAN', 'DE21500500009876543210')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/DbtrAcct/Id/IBAN', 'DE68210501700012345678')
        end

        it 'should contain <RmtInf>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[1]/RmtInf/Ustrd', 'Unsere Rechnung vom 10.08.2013')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf/DrctDbtTxInf[2]/RmtInf/Ustrd', 'Vielen Dank fuer Ihren Einkauf')
        end
      end

      context 'with different requested_date given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2)

          sdd.to_xml
        end

        it 'should contain two payment_informations with <ReqdColltnDt>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/ReqdColltnDt', (Date.today + 1).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/ReqdColltnDt', (Date.today + 2).iso8601)

          subject.should_not have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end
      end

      context 'with different local_instrument given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge local_instrument: 'CORE')
          sdd.add_transaction(direct_debt_transaction.merge local_instrument: 'B2B')
          sdd.add_transaction(direct_debt_transaction.merge local_instrument: 'B2B')

          sdd.to_xml
        end

        it 'should contain two payment_informations with <LclInstrm>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtTpInf/LclInstrm/Cd', 'CORE')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtTpInf/LclInstrm/Cd', 'B2B')

          subject.should_not have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end
      end

      context 'with different sequence_type given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge sequence_type: 'OOFF')
          sdd.add_transaction(direct_debt_transaction.merge sequence_type: 'FRST')
          sdd.add_transaction(direct_debt_transaction.merge sequence_type: 'FRST')

          sdd.to_xml
        end

        it 'should contain two payment_informations with <LclInstrm>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtTpInf/SeqTp', 'OOFF')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtTpInf/SeqTp', 'FRST')

          subject.should_not have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end
      end

      context 'with different batch_booking given' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge batch_booking: false)
          sdd.add_transaction(direct_debt_transaction.merge batch_booking: true)
          sdd.add_transaction(direct_debt_transaction.merge batch_booking: true)

          sdd.to_xml
        end

        it 'should contain two payment_informations with <BtchBookg>' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/BtchBookg', 'false')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/BtchBookg', 'true')

          subject.should_not have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]')
        end
      end

      context 'with transactions containing different group criteria' do
        subject do
          sdd = direct_debit

          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1, local_instrument: 'CORE', sequence_type: 'OOFF', amount: 1)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1, local_instrument: 'CORE', sequence_type: 'FNAL', amount: 2)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1, local_instrument: 'B2B',  sequence_type: 'OOFF', amount: 4)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 1, local_instrument: 'B2B',  sequence_type: 'FNAL', amount: 8)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2, local_instrument: 'CORE', sequence_type: 'OOFF', amount: 16)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2, local_instrument: 'CORE', sequence_type: 'FNAL', amount: 32)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2, local_instrument: 'B2B',  sequence_type: 'OOFF', amount: 64)
          sdd.add_transaction(direct_debt_transaction.merge requested_date: Date.today + 2, local_instrument: 'B2B',  sequence_type: 'FNAL', amount: 128)

          sdd.to_xml
        end

        it 'should contain multiple payment_informations' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/ReqdColltnDt', (Date.today + 1).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtTpInf/LclInstrm/Cd', 'CORE')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/PmtTpInf/SeqTp', 'OOFF')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/ReqdColltnDt', (Date.today + 1).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtTpInf/LclInstrm/Cd', 'CORE')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/PmtTpInf/SeqTp', 'FNAL')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/ReqdColltnDt', (Date.today + 1).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/PmtTpInf/LclInstrm/Cd', 'B2B')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/PmtTpInf/SeqTp', 'OOFF')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/ReqdColltnDt', (Date.today + 1).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/PmtTpInf/LclInstrm/Cd', 'B2B')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/PmtTpInf/SeqTp', 'FNAL')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[5]/ReqdColltnDt', (Date.today + 2).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[5]/PmtTpInf/LclInstrm/Cd', 'CORE')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[5]/PmtTpInf/SeqTp', 'OOFF')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[6]/ReqdColltnDt', (Date.today + 2).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[6]/PmtTpInf/LclInstrm/Cd', 'CORE')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[6]/PmtTpInf/SeqTp', 'FNAL')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[7]/ReqdColltnDt', (Date.today + 2).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[7]/PmtTpInf/LclInstrm/Cd', 'B2B')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[7]/PmtTpInf/SeqTp', 'OOFF')

          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[8]/ReqdColltnDt', (Date.today + 2).iso8601)
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[8]/PmtTpInf/LclInstrm/Cd', 'B2B')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[8]/PmtTpInf/SeqTp', 'FNAL')
        end

        it 'should have multiple control sums' do
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[1]/CtrlSum', '1.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[2]/CtrlSum', '2.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[3]/CtrlSum', '4.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[4]/CtrlSum', '8.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[5]/CtrlSum', '16.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[6]/CtrlSum', '32.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[7]/CtrlSum', '64.00')
          subject.should have_xml('//Document/CstmrDrctDbtInitn/PmtInf[8]/CtrlSum', '128.00')
        end
      end
    end
  end
end
