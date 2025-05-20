import { Pessoa } from './models/Pessoa';
import { Voluntario } from './models/Voluntario';
import { Beneficiario } from './models/Beneficiario';
import { Item } from './models/Item';
import { Doacao } from './models/Doacao';
import { PessoaRepository } from './repositories/PessoaRepository';
import { VoluntarioRepository } from './repositories/VoluntarioRepository';
import { BeneficiarioRepository } from './repositories/BeneficiarioRepository';
import { ItemRepository } from './repositories/ItemRepository';
import { DoacaoRepository } from './repositories/DoacaoRepository';

async function cleanup() {
    const doacaoRepo = new DoacaoRepository();
    const itemRepo = new ItemRepository();
    const voluntarioRepo = new VoluntarioRepository();
    const beneficiarioRepo = new BeneficiarioRepository();
    const pessoaRepo = new PessoaRepository();

    try {
        // Limpar todas as doações e itens
        const doacoes = await doacaoRepo.findAll();
        for (const doacao of doacoes) {
            await doacaoRepo.delete(doacao.getId());
        }

        // Limpar todos os itens
        const itens = await itemRepo.findAll();
        for (const item of itens) {
            await itemRepo.delete(item.getId());
        }

        // Limpar voluntários e beneficiários
        const voluntarios = await voluntarioRepo.findAll();
        for (const voluntario of voluntarios) {
            await voluntarioRepo.delete(voluntario.getId());
        }

        const beneficiarios = await beneficiarioRepo.findAll();
        for (const beneficiario of beneficiarios) {
            await beneficiarioRepo.delete(beneficiario.getId());
        }

        // Limpar pessoas
        const pessoas = await pessoaRepo.findAll();
        for (const pessoa of pessoas) {
            await pessoaRepo.delete(pessoa.getId());
        }
    } catch (error) {
        console.error('Erro durante limpeza:', error);
    }
}

async function main() {
    try {
        // Limpar dados de teste anteriores
        await cleanup();

        // Criar repositórios
        const pessoaRepo = new PessoaRepository();
        const voluntarioRepo = new VoluntarioRepository();
        const beneficiarioRepo = new BeneficiarioRepository();
        const itemRepo = new ItemRepository();
        const doacaoRepo = new DoacaoRepository();

        console.log('=== Registrando Voluntário ===');
        // Registrar voluntário
        const pessoaVoluntario = new Pessoa(
            0,
            'João Silva',
            '12345678902', // CPF alterado
            '(11) 99999-9999',
            'joao@email.com',
            'Rua A, 123'
        );
        const pessoaVoluntarioSalva = await pessoaRepo.create(pessoaVoluntario);
        const voluntario = new Voluntario(
            pessoaVoluntarioSalva.getId(),
            pessoaVoluntarioSalva.getNome(),
            pessoaVoluntarioSalva.getCpf(),
            pessoaVoluntarioSalva.getTelefone(),
            pessoaVoluntarioSalva.getEmail(),
            pessoaVoluntarioSalva.getEndereco()
        );
        const voluntarioSalvo = await voluntarioRepo.create(voluntario);
        console.log('Voluntário registrado:', voluntarioSalvo);

        console.log('\n=== Registrando Beneficiário ===');
        // Registrar beneficiário
        const pessoaBeneficiario = new Pessoa(
            0,
            'Maria Santos',
            '98765432102', // CPF alterado
            '(11) 98888-8888',
            'maria@email.com',
            'Rua B, 456'
        );
        const pessoaBeneficiarioSalva = await pessoaRepo.create(pessoaBeneficiario);
        const beneficiario = new Beneficiario(
            pessoaBeneficiarioSalva.getId(),
            pessoaBeneficiarioSalva.getNome(),
            pessoaBeneficiarioSalva.getCpf(),
            pessoaBeneficiarioSalva.getTelefone(),
            pessoaBeneficiarioSalva.getEmail(),
            pessoaBeneficiarioSalva.getEndereco(),
            1500.00
        );
        const beneficiarioSalvo = await beneficiarioRepo.create(beneficiario);
        console.log('Beneficiário registrado:', beneficiarioSalvo);

        console.log('\n=== Registrando Itens ===');
        // Registrar itens
        const item1 = new Item(
            0,
            'ROUPA',
            'Camiseta azul',
            'M',
            'NOVA',
            'ADULTO',
            'DISPONIVEL'
        );
        const item2 = new Item(
            0,
            'ROUPA',
            'Calça jeans',
            '42',
            'USADA',
            'ADULTO',
            'DISPONIVEL'
        );
        const item1Salvo = await itemRepo.create(item1);
        const item2Salvo = await itemRepo.create(item2);
        console.log('Itens registrados:', [item1Salvo, item2Salvo]);

        console.log('\n=== Registrando Doação ===');
        // Registrar doação
        const doacao = new Doacao(
            0,
            voluntarioSalvo,
            beneficiarioSalvo,
            [item1Salvo, item2Salvo],
            new Date(),
            'RECEBIDA',
            'PENDENTE',
            'Doação de roupas'
        );
        const doacaoSalva = await doacaoRepo.create(doacao);
        console.log('Doação registrada:', doacaoSalva);

        console.log('\n=== Listando Todas as Doações ===');
        const todasDoacoes = await doacaoRepo.findAll();
        console.log('Total de doações:', todasDoacoes.length);
        todasDoacoes.forEach(d => {
            console.log(`\nDoação #${d.getId()}:`);
            console.log('Voluntário:', d.getVoluntario().getNome());
            console.log('Beneficiário:', d.getBeneficiario().getNome());
            console.log('Status:', d.getStatus());
            console.log('Itens:', d.getItens().map(i => i.getDescricao()).join(', '));
        });

        console.log('\n=== Buscando Beneficiário por CPF ===');
        const beneficiarioEncontrado = await beneficiarioRepo.findByCpf('98765432102');
        console.log('Beneficiário encontrado:', beneficiarioEncontrado);

        console.log('\n=== Atualizando Status da Doação ===');
        doacaoSalva.setStatus('CONCLUIDA');
        const doacaoAtualizada = await doacaoRepo.update(doacaoSalva);
        console.log('Doação atualizada:', doacaoAtualizada);

    } catch (error) {
        console.error('Erro durante a execução:', error);
    }
}

main(); 