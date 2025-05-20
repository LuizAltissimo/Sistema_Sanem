import { BaseRepository } from './BaseRepository';
import { Beneficiario } from '../models/Beneficiario';
import { PessoaRepository } from './PessoaRepository';

export class BeneficiarioRepository extends BaseRepository<Beneficiario> {
    private pessoaRepo: PessoaRepository;

    constructor() {
        super();
        this.pessoaRepo = new PessoaRepository();
    }

    async create(beneficiario: Beneficiario): Promise<Beneficiario> {
        const result = await this.pool.query(
            'INSERT INTO Beneficiario (id_pessoa, renda) VALUES ($1, $2) RETURNING *',
            [beneficiario.getId(), beneficiario.getRenda()]
        );
        return new Beneficiario(
            result.rows[0].id_beneficiario,
            beneficiario.getNome(),
            beneficiario.getCpf(),
            beneficiario.getTelefone(),
            beneficiario.getEmail(),
            beneficiario.getEndereco(),
            result.rows[0].renda
        );
    }

    async findById(id: number): Promise<Beneficiario | null> {
        const result = await this.pool.query(
            'SELECT b.*, p.* FROM Beneficiario b JOIN Pessoa p ON b.id_pessoa = p.id_pessoa WHERE b.id_beneficiario = $1',
            [id]
        );
        if (result.rows.length === 0) {
            return null;
        }
        return new Beneficiario(
            result.rows[0].id_beneficiario,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco,
            result.rows[0].renda
        );
    }

    async findByCpf(cpf: string): Promise<Beneficiario | null> {
        const result = await this.pool.query(
            'SELECT b.*, p.* FROM Beneficiario b JOIN Pessoa p ON b.id_pessoa = p.id_pessoa WHERE p.cpf = $1',
            [cpf]
        );
        if (result.rows.length === 0) {
            return null;
        }
        return new Beneficiario(
            result.rows[0].id_beneficiario,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco,
            result.rows[0].renda
        );
    }

    async findAll(): Promise<Beneficiario[]> {
        const result = await this.pool.query(
            'SELECT b.*, p.* FROM Beneficiario b JOIN Pessoa p ON b.id_pessoa = p.id_pessoa'
        );
        return result.rows.map(row => new Beneficiario(
            row.id_beneficiario,
            row.nome,
            row.cpf,
            row.telefone,
            row.email,
            row.endereco,
            row.renda
        ));
    }

    async update(beneficiario: Beneficiario): Promise<Beneficiario> {
        const result = await this.pool.query(
            'UPDATE Beneficiario SET renda = $1 WHERE id_beneficiario = $2 RETURNING *',
            [beneficiario.getRenda(), beneficiario.getId()]
        );
        return new Beneficiario(
            result.rows[0].id_beneficiario,
            beneficiario.getNome(),
            beneficiario.getCpf(),
            beneficiario.getTelefone(),
            beneficiario.getEmail(),
            beneficiario.getEndereco(),
            result.rows[0].renda
        );
    }

    async delete(id: number): Promise<void> {
        await this.pool.query('DELETE FROM Beneficiario WHERE id_beneficiario = $1', [id]);
    }
} 